# cc-secure-login
ComputerCraft Secure Login
- Light weight login system
- Use SHA-265 hashing
- Recovery Disk to bypass login

## Installer
Run this command to install secure login on your computer:
```
wget run https://raw.githubusercontent.com/Konijima/cc-secure-login/master/installer.lua
```

## Setup
After installing, run this command to setup secure login:
```lua
secure/setup.lua
```

## Recovery
If a disk with a floppy inside is found during the setup, you will be prompted to create a recovery disk.

Using a valid recovery disk will bypass the login screen on reboot, **so keep it safe**.

## Startup
If you want your startup to do other thing after login just edit it and add what you want after the first line.  
```
-- File: startup.lua
shell.run('/secure/login') -- execute the login first

-- My other stuff here
```
