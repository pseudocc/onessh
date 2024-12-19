# ONESSH

The OneSSH is an administrative tool to manage single SSH login over
multiple users. To be able to SSH into the device, each user need to
check-in the device first.

## Installation & Configuration

You can specify the environment variable `ONESSH_ALLOWED_USERS` for a quick
setup. Otherwise, you need to add this in `/home/onechad/.onesshrc` and
import SSH keys into `/home/onechad/.ssh/authorized_keys` manually.

```bash
sudo ONESSH_ALLOWED_USERS="lpuser1 lpuser2" dpkg -i onessh_amd64.deb
```

You may specify `ONESSH_IMPORT_KEYFILE` instead of `ONESSH_ALLOWED_USERS`
during the installation/configuration time this will parse the comments
in the SSH key file and get all the launchpad users and set `ONESSH_ALLOWED_USERS`.

```bash
sudo ONESSH_IMPORT_KEYFILE=/etc/ssh/authorized_keys dpkg -i onessh_amd64.deb
```

Another configurable is `ONESSH_SHARED_LOGIN` which controls the shared
login behavior.

    - "all": (default) all users can login when no user is checked-in.
    - "one": only the checked-in user.
    - "none": disable shared login.

if `ONESSH_SHARED_USERS` is not defined, then the current user will be
considered to be the "shared user".

## Usage

Users in `ONESSH_ALLOWED_USERS` are able to run the following command to
enter the OneSSH login shell.

```bash
ssh onechad@host
```

Inside the login shell, run `checkin` to reserve the device.

```bash
checkin lpuser1 now + 23 hours
```

Then lpuser1 would be able to SSH into the device.

```bash
ssh lpuser1@host
```

Suppose "ubuntu" is included in `ONESSH_SHARED_USERS`, lpuser1 could also
connect to the host via:

```bash
ssh ubuntu@host
```

Run `checkout` to release immediately or at certain time.

Run `status` to check the checked-in state and the scheduled checkout time.

You could also run commands directly without entering the login shell.

```bash
ssh onechad@host status
```

### Advanced

You may set `ONESSH_SHARED_LOGIN` during the installation time, or modify it in
the `.onesshrc` file. It defines how the `OneSSH` would react to the shared
user login when no user is checked-in.

- all:  all users can login when no user is checked-in
- one:  only the checked-in user
- none: disable shared login when no user is checked-in
              (Please make sure you know what you are doing)

The default behavior is `all`.

### Help

List all commands and brief help message for the onessh shell.

```bash
ssh onechad@host help
```

For each individual commands, use option `-h/--help` to see the full
help message.

```bash
ssh onechad@host status -h
ssh onechad@host checkin --help
```
