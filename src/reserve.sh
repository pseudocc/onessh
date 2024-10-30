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

ONESSH_KEY_DIR=/etc/ssh/onessh/keys
ONESSH_GROUP=onessh
source "$ONESSH_LIB/utils.sh"

# Create an user if it does not exist, the user has no password and can only
# access the device by ssh key.
ensure_user() {
	local user_name ssh_key_file key_exists
	user_name="$1"

	if [ -z "$ONESSH_ALLOWED_USERS" ]; then
		print_error "\$ONESSH_ALLOWED_USERS is not set"
		exit 1
	fi

	# shellcheck disable=SC2206
	ONESSH_ALLOWED_USERS_ARR=($ONESSH_ALLOWED_USERS)
	for allowed_user in "${ONESSH_ALLOWED_USERS_ARR[@]}"; do
		if [ "$user_name" = "$allowed_user" ]; then
			break
		fi
	done
	if [ "$user_name" != "$allowed_user" ]; then
		print_error "User [$user_name] is not allowed to check-in"
		exit 1
	fi

	if ! id -u "$user_name" &> /dev/null; then
		if ! sudo useradd -m -s /bin/bash -G "$ONESSH_GROUP" "$user_name"; then
			print_error "Failed to create user [$user_name]"
			exit 1
		fi
		if ! sudo usermod -aG sudo "$user_name"; then
			print_error "Failed to add user [$user_name] to group [sudo]"
			exit 1
		fi
		if ! sudo passwd -d "$user_name" &> /dev/null; then
			print_error "Failed to remove password of user [$user_name]"
			exit 1
		fi
	else
		if ! sudo usermod -aG "$ONESSH_GROUP" "$user_name"; then
			print_error "Failed to add user [$user_name] to group" \
				"[$ONESSH_GROUP]"
			exit 1
		fi
	fi

	ssh_key_file="$(onessh_key_file "$user_name")"
	if [ -f "$ssh_key_file" ]; then
		key_exists=1
	fi

	if ! sudo ssh-import-id lp:"$user_name" -o "$ssh_key_file" &> /dev/null; then
		print_error "Failed to import ssh key of user" \
			"[$user_name] from Launchpad"
		exit 1
	fi

	if [ -z "$key_exists" ]; then
		sudo chown "$user_name:$ONESSH_GROUP" "$ssh_key_file"
		sudo chmod 0 "$ssh_key_file"
	fi
}

onessh_key_file() {
	local user_name="$1"
	echo "$ONESSH_KEY_DIR/$user_name"
}

has_checked_in() {
	local ssh_key_file="$1"
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
	if ! id -u "$user_name" &> /dev/null; then
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

shared_keys() {
	local user_name
	case "$ONESSH_SHARED_LOGIN" in
		none)
			return 1
			;;
		all|one)
			;;
		*)
			print_error "Invalid value [$ONESSH_SHARED_LOGIN] for" \
				"\$ONESSH_SHARED_LOGIN"
			exit 1
			;;
	esac

	for file in "$ONESSH_KEY_DIR"/*; do
		if [ "$ONESSH_SHARED_LOGIN" = "all" ]; then
			sudo cat "$file"
			continue
		fi
		# [ "$ONESSH_SHARED_LOGIN" = "one" ]
		if has_checked_in "$file"; then
			user_name="$(basename "$file")"
			sudo -u "$user_name" cat "$file"
			return 0
		fi
	done
	return 1
}

if [ -n "$ONESSH_VERBOSE" ]; then
	set -x
fi
