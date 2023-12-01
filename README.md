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

Run `checkout` to release immediately or at certain time.

Run `status` to check the checked-in state and the scheduled checkout time.

You could also run commands directly without entering the login shell.

```bash
ssh onechad@host status
```
