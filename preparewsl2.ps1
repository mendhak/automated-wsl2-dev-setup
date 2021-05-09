#Requires -RunAsAdministrator

New-Item -ItemType Directory -Force -Path C:\Temp
$wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -Property State
$rebootrequired=0

if($wslenabled.State -eq "Disabled")
{
    Write-Host "WSL is not enabled.  Enabling now." -ForegroundColor Yellow -BackgroundColor DarkGreen
    # Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    $rebootrequired=1
    
}
else {
    Write-Host "WSL already enabled. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen
}



$vmenabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -Property State

if($vmenabled.State -eq "Disabled")
{
    Write-Host "VirtualMachinePlatform is not enabled.  Enabling now." -ForegroundColor Yellow -BackgroundColor DarkGreen
    # Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    $rebootrequired=1
}
else {
    Write-Host "VirtualMachinePlatform already enabled. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen
}

if($rebootrequired -eq 1){
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host "PLEASE REBOOT, then run this script again.  " -ForegroundColor Yellow -BackgroundColor DarkGreen
    Write-Host "============================================" -ForegroundColor Yellow -BackgroundColor DarkGreen
    exit
}


if(!(Test-Path "C:\Temp\wsl_update_x64.msi"))
{
    Write-Host "Downloading the Linux kernel update package. Please wait." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Start-BitsTransfer -Source "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -Destination "C:\Temp\wsl_update_x64.msi" -Description "Downloading Linux kernel update package"
}
else 
{
    Write-Host "The Linux kernel update package already at C:\Temp\wsl_update_x64.msi. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen
}

Write-Host "Installing the Linux kernel update package." -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process 'msiexec' -ArgumentList '/quiet /i C:\Temp\wsl_update_x64.msi' -Wait -NoNewWindow
# msiexec /i C:\Temp\wsl_update_x64.msi


if(!(Test-Path "C:\Temp\UBUNTU2004.appx"))
{
    Write-Host "Downloading the Ubuntu 20.04 image. Please wait." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Start-BitsTransfer -Source "https://aka.ms/wslubuntu2004" -Destination "C:\Temp\UBUNTU2004.appx" -Description "Downloading Ubuntu 20.04 WSL image"
}
else 
{
    Write-Host "The Ubuntu 20.04 image was already at C:\Temp\UBUNTU2004.appx. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen
}

$ubu2004appxinstalled = Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu20.04onWindows

if($ubu2004appxinstalled){
    Write-Host "Ubuntu 20.04 appx is already installed. Moving on." -ForegroundColor Yellow -BackgroundColor DarkGreen
}
else {
    Write-Host "Installing the Ubuntu 20.04 Appx distro. Please wait." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Add-AppxPackage -Path "C:\Temp\UBUNTU2004.appx"

}


Write-Host "Configuring Ubuntu 20.04... " -ForegroundColor Yellow -BackgroundColor DarkGreen
Write-Host "Initialise Ubuntu distro" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu2004.exe" -ArgumentList "install --root" -Wait -NoNewWindow
Write-Host "Set /c/ as mount point"
Start-Process "ubuntu2004.exe" -ArgumentList "run echo '[automount]' > /etc/wsl.conf" -Wait -NoNewWindow
Start-Process "ubuntu2004.exe" -ArgumentList "run echo 'root = /' >> /etc/wsl.conf" -Wait -NoNewWindow
Restart-Service LxssManager
Start-Sleep -s 5

$username = Read-Host -Prompt 'The WSL user name you want'

Write-Host "Create the $username user " -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu2004.exe" -ArgumentList "run adduser $username --gecos 'First,Last,RoomNumber,WorkPhone,HomePhone' --disabled-password" -Wait -NoNewWindow
Write-Host "Add $username to sudo group" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu2004.exe" -ArgumentList "run usermod -aG sudo $username" -Wait -NoNewWindow
Write-Host "Allow $username to run apt updates" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu2004.exe" -ArgumentList "run echo '$username ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" -Wait -NoNewWindow
Write-Host "Ask for $username password to set" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu2004.exe" -ArgumentList "run passwd $username" -Wait -NoNewWindow
Write-Host "Set WSL default user to $username" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "ubuntu2004.exe" -ArgumentList "config --default-user $username" -Wait -NoNewWindow
Write-Host "Update Ubuntu 20.04 and install some packages" -ForegroundColor Yellow -BackgroundColor DarkGreen
Start-Process "WSL" -ArgumentList "bash preparewsl2.sh" -Wait -NoNewWindow

Write-Host "Installing Docker Desktop" -ForegroundColor Yellow -BackgroundColor DarkGreen

if(!(Test-Path "C:\Temp\docker-desktop-installer.exe"))
{
    Write-Host "Downloading the Docker Desktop installer." -ForegroundColor Yellow -BackgroundColor DarkGreen
    Start-BitsTransfer -Source "https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -Destination "C:\Temp\docker-desktop-installer.exe" -Description "Downloading Docker Desktop"
}

Start-Process 'C:\Temp\docker-desktop-installer.exe' -ArgumentList 'install --quiet' -Wait -NoNewWindow

# When Docker Desktop detects WSL2, it automatically installs Docker client in there.  
Write-Host "Waiting for Docker Desktop to start" -ForegroundColor Yellow -BackgroundColor DarkGreen
& 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
Start-Sleep -s 30

Write-Host "Done." -ForegroundColor Yellow -BackgroundColor DarkGreen