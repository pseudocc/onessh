# ONESSH

The OneSSH is an administrative tool to manage single SSH login over multiple users.
To be about to SSH into the device, each user need to check-in the device first.

## Installation & Configuration

You can specify the environment variable `ONESSH_ALLOWED_USERS` for quick env setup.
Otherwise, you need to add this in `/home/onessh-chad/.onesshrc` and import SSH keys
manually into `/home/onessh-chad/.ssh/authorized_keys`.

```
ONESSH_ALLOWED_USERS="lpuser1 lpuser2" sudo -E dpkg -i onessh_amd64.deb
```

## Usage

Users in `ONESSH_ALLOWED_USERS` are able to run the following command to enter the
OneSSH login shell.

```
ssh onessh-chad@host
```

Inside the login shell, run `checkin` to reserve the device.

```
checkin lpuser1 now + 23 hours
```

Then lpuser1 would be able to SSH into the device.

```
ssh lpuser1@host
```

Run `checkout` to release immediately or at certain time.

Run `status` to check the checked-in state and the scheduled checkout time.
