# vim: noet
#
# The script is used to check-in and check-out the device. It is designed to
# make sure only one user can access the device at a time.
# 
# The mechanism is simple: the user who wants to use the device must check-in
# the device first, and then check-out the device when he/she finishes using.
#
# In /etc/ssh/sshd_config.d/onessh.conf:
# AuthorizedKeyFile /etc/ssh/onessh_keys/%u
#
# And by adjusting the permissions of /etc/ssh/onessh_keys, we can make sure
# only the user who has checked-in the device can access the device.

export ONESSH_KEY_DIR=/etc/ssh/onessh_keys
source "$ONESSH_LIB/utils.sh"

# Create an user if it does not exist, the user has no password and can only
# access the device by ssh key.
ensure_user() {
	local user_name ssh_key_file
	user_name="$1"
	if id -u "$user_name" >/dev/null 2>&1; then
		return 0
	fi

	if [ -z "${ONESSH_ALLOWED_USERS[*]}" ]; then
		print_error "ONESSH_ALLOWED_USERS is not set"
		exit 1
	fi

	for allowed_user in "${ONESSH_ALLOWED_USERS[@]}"; do
		if [ "$user_name" = "$allowed_user" ]; then
			break
		fi
	done
	if [ "$user_name" != "$allowed_user" ]; then
		print_error "User [$user_name] is not allowed to check-in"
		exit 1
	fi

	if ! sudo useradd -m -s /bin/bash "$user_name"; then
		print_error "Failed to create user [$user_name]"
		exit 1
	fi
	if ! sudo passwd -d "$user_name"; then
		print_error "Failed to remove password of user [$user_name]"
		exit 1
	fi

	ssh_key_file="$(onessh_key_file "$user_name")"
	if ! ssh-import-id lp:"$user_name" -o "$ssh_key_file"; then
		print_error "Failed to import ssh key of user" \
			"[$user_name] from Launchpad"
		exit 1
	fi
	sudo chown "$user_name:$user_name" "$ssh_key_file"
	sudo chmod 0 "$ssh_key_file"
}

onessh_key_file() {
	local user_name="$1"
	echo "$ONESSH_KEY_DIR/$user_name"
}

has_checked_in() {
	ssh_key_file="$1"
	if [ "$(stat -c "%a" "$ssh_key_file")" = "400" ]; then
		return 0
	else
		return 1
	fi
}

check_in() {
	local user_name ssh_key_file
	user_name="$1"
	ssh_key_file="$(onessh_key_file "$user_name")"

	ensure_user "$user_name"
	if has_checked_in "$ssh_key_file"; then
		print_error "User [$user_name] has already checked-in"
		exit 1
	fi

	for file in "$ONESSH_KEY_DIR"/*; do
		if [ "$file" = "$ssh_key_file" ]; then
			continue
		fi
		if has_checked_in "$file"; then
			print_error "User [$(basename "$file")] has not" \
				"checked-out, please wait"
			exit 1
		fi
	done
	sudo chmod 400 "$ssh_key_file"
}

check_out() {
	local user_name ssh_key_file
	user_name="$1"
	if ! id -u "$user_name" >/dev/null 2>&1; then
		print_error "User [$user_name] does not exist"
		sudo rm -f "$(onessh_key_file "$user_name")"
		exit 1
	fi

	ssh_key_file="$(onessh_key_file "$user_name")"
	if ! has_checked_in "$ssh_key_file"; then
		print_error "User [$user_name] has not checked-in"
		exit 1
	fi
	sudo chmod 0 "$ssh_key_file"
}