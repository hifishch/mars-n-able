#Powershell MARS Backup Start for Solarwinds RMM
#Author: Andreas Walker andreas.walker@walkerit.ch
#Licence: GNU General Public License v3.0
#Version: 1.0.0 / 21.10.2019

#Check if MARS is installed
if (!(Test-Path 'C:\Program Files\Microsoft Azure Recovery Services Agent\bin\Modules\MSOnlineBackup'))
    {
    Write-Host "MARS is not installed. Quitting."
    Exit 1001
    }

#Import PS-Module
Import-Module -Name 'C:\Program Files\Microsoft Azure Recovery Services Agent\bin\Modules\MSOnlineBackup'

#Initiating Backup
Get-OBPolicy | Start-OBBackup

#Get last Backup
$LastRestorePoint = Get-OBAllRecoveryPoints | Select-Object -first 1

#Set Time-Variables
$RefTime = (Get-Date).AddDays(-1)

#Generating Output
if ($LastRestorePoint.BackupTime -ge $RefTime)
    {
    Write-Host "OK"
    Write-Host "The last backup has been preformed at"$LastRestorePoint.BackupTime
    Exit 0
    }
else
    {
    Write-Host "Error: The last Backup is older than 24 hours"
    Write-Host "The last backup has been preformed at"$LastRestorePoint.BackupTime
    Exit 1001
    }

Write-Host "The Script came to an unexpected end."
Exit 1001