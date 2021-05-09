Sets up WSL2 with Ubuntu 20.04.  Configures Ubuntu, installs Docker Desktop.  

To run it,

```
powershell -executionpolicy bypass -file .\preparewsl2.ps1
```

A reboot is required in between.  The script will also prompt you for a username and password to use in the Ubuntu setup.
