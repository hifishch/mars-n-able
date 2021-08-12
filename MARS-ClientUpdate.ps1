#Powershell MARS Update Check for N-able RMM
#Author: Andreas Walker andreas.walker@walkerit.ch
#Licence: GNU General Public License v3.0
#Version: 1.0.0 / 12.10.2019

#Define Temp-Path for MARS-installer
$InstallerFolder= 'C:\temp'
$InstallerPath = 'C:\temp\MARSAgentInstaller.exe'
$InstalledBinary = 'C:\Program Files\Microsoft Azure Recovery Services Agent\bin\AutoUpdateAgent.exe'
$MarsURL = 'https://aka.ms/Azurebackup_Agent'

#Defining functions

function Get-MARSInstaller
    {
    if (!(Test-Path $InstallerFolder)
        {
        New-Item -Path "C:\" -Name "temp" -ItemType "directory" -force | Out-Null
        }
    Invoke-WebRequest -Uri $MarsURL -OutFile $InstallerPath -UseBasicParsing
    if (!(Test-Path $InstallerPath))
        {
        Write-Host "FAILURE - Download from $MarsURL to $InstallerPath failed."
        Exit 1001
        }
    }

function Remove-MARSInstallerFile
    {
    if (Test-Path $InstallerPath) 
        {
        Remove-Item $InstallerPath
        }
    }

function Install-MARS
    {
    $param = '/q'
    $cmd = "$InstallerPath $param"
    Write-Host "MARS installer triggered. $cmd"
    Start-Process -FilePath $InstallerPath -ArgumentList $param -Wait
    Write-Host "Installer-routine terminated."
    Remove-MARSInstallerFile
    }


function Verify-Installation
    {
    $NewInstalledVersion = (Get-Item $InstalledBinary).VersionInfo.ProductVersion
        if (!($NewInstalledVersion -eq $DownloadedVersion))
        {
        Write-Host "FAILURE - Installation did not work! Version missmatch."
        Exit 1001
        }
        else
        {
        Write-Host "OK - MARS version $NewInstalledVersion has been installed!"
        }
    }

#Check if MARS is installed and has parsable Version
if (Test-Path $InstalledBinary)
    {
    $CurrentVersion = (Get-Item $InstalledBinary).VersionInfo.ProductVersion
    Write-Host "Found installed MARS-version:" $CurrentVersion
    Remove-MARSInstallerFile
    Get-MARSInstaller
    $DownloadedVersion = (Get-Item $InstallerPath).VersionInfo.ProductVersion
    Write-Host "Downloaded MARS-installer for version" $DownloadedVersion
     if ($DownloadedVersion -gt $CurrentVersion)
        {
        Install-MARS
        Verify-Installation
        Exit 0 
        }
        else
            {
            Write-Host "OK - No update needed. Installed version is $CurrentVersion"
            Remove-MARSInstallerFile
            Exit 0
            }
    }
else 
    {
    Write-Host "FAULURE - No MARS-installation found."
    Exit 1001
    }


#Catch unexpected end of Script
Write-Host "FAILURE - Script ended unexpected"
Exit 1001
