# Powershell

---
The following are a collection of Powershell snippets and one-liners for your use. 

All commands are Powershell and CMD-compatible unless stated otherwise. 

Hope they help!

## Table of Contents

I. [One-Liners](#one-liners)

II. [Snippets](#snippets)
<br>&nbsp; 1. [Clear Print Spooler](#clear-print-spooler)
<br>&nbsp; 2. [Blink NIC](#blink-nic)
<br>&nbsp; 3. [Create Monthly Folders](#create-monthly-folders)

III. [Active Directory Snippets](#active-directory-snippets)
<br>&nbsp; 1. [Stale AD Computers](#stale-ad-computers)
<br>&nbsp; 2. [Stale AD Users](#stale-ad-users)
<br>&nbsp; 3. [Hard match On-Prem user account to Entra](#hard-match-on-prem-user-account-to-entra)
<br>&nbsp; 4. [Re-run AD-Agent Sync](#re-run-ad-agent-sync)
<br>&nbsp; 4. [Read a CSV](#read-a-csv)
<br>&nbsp; 5. [Disable Computer Objects and Move to OU](#disable-computer-objects-and-move-to-ou)
<br>&nbsp; 6. [Enable Bitlocker and Manually Upload Key to AD](#enable-bitlocker-and-manually-upload-key-to-ad)

IV. [Run](#run)
<br>&nbsp; 1. [Windows Environment Path Variables](#windows-environment-path-variables)
<br>&nbsp; 2. [Run Commands](#run-commands)
<br>&nbsp; 3. [Microsoft Office Suite](#microsoft-office-suite)
<br>&nbsp; 4. [Management Consoles](#management-consoles)
<br>&nbsp; 5. [Control Panel Utilities](#control-panel-utilities)

## One-Liners
---

### Kills process by name or Process Id.
```powershell
Stop-Process -Name "<nameOfProcess>" -Id <PID>
```

### Kills process using the kill command. I've had better results with this over Stop-Process.
```powershell
Get-Process | Where-Object {$_.Name -eq "<ProcessName>"} | kill
```


### Shows currently running processes. Similar to top in Linux. Use with \<name\> to display attributes of specific process.
```powershell
Get-Process <name>
```


### Kills process forcefully by name. Primarily a CMD command.
```cmd
taskkill /f /fi "IMAGENAME eq <processName.exe>"
```


### Shows saved Wi-Fi Profiles. Works with the word profile or profiles.
```cmd
netsh wlan show profiles
```


### Deletes saved Wi-Fi Profiles. Can use wildcard *
```cmd
netsh wlan delete profile <profileName>
```


### Shows Wi-Fi profile properties including cleartext Wi-Fi password.
```cmd
netsh wlan show profile name="<SSID>" key=clear
```

### Exports Wi-Fi profile properties to file. With cleartext Wifi password.
```cmd
netsh wlan export profile name="<SSID>" folder="<filepath>" key=clear
```


### Change Time Zone. Can be done in CMD too.
```cmd
tzutil /s "Time Zone"
```


### Change a local users password. use /add to create account
```cmd
net users <username> <password> </add>
```


---
## Snippets
---

### Clear Print Spooler
Description: Clears out the print spooler. Helpful if there are stuck print jobs.

Must be run as admin.

```powershell
net stop spooler

Remove-Item "C:\WINDOWS\system32\spool\PRINTERS\*" -Confirm

net start spooler
```


---
### Blink NIC
Description: Script that asks for the name of the NIC you would like to enable and 
disable indefinitely. Useful if you're trying to track down a NIC port
on a switch.
Hit Ctrl+C to exit.

Must be run as admin.
```powershell
# Defines function named blinkNic that takes $adapterName string argument.
Function blinkNic([String]$adapterName)
{

# Confirm:$false bypasses confirmation prompt.
Disable-NetAdapter -Name "$adapterName" -Confirm:$false

# Waits 2 seconds before continuing with script.
Start-Sleep "2"

Enable-NetAdapter -Name "$adapterName" -Confirm:$false

Start-Sleep "2"

}

$adapterName = Read-Host "Please enter the name of the adapter you would like to blink."
DO
{
blinkNic($adapterName)
} WHILE($true)
```


---
### Create monthly folders
Description: Creates 12 folders for each month. Folder titles can be customized.

Must be run as admin.

```powershell
Set-ExecutionPolicy Bypass

foreach ($month in 1..12)
{

# For Testing
Write-Host $month"-2025"

New-Item -Path "." -Name $month"-2025" -ItemType Directory

}
```



---
## Active Directory Snippets
---
The following are exclusively to get information from Active Directory.

---


### Stale AD Computers
Description: Creates a CSV file with all computers that have not checked in
to the domain in more than 120 days.

Must be run on Domain Controller.

```powershell
# Number of days you want to search for computer inactivity
$days_PC_Inactive = 80

# Converts $stale_PC_Time to $DaysInactive

$stale_PC_Time = (Get-Date).AddDays(-($days_PC_Inactive))

$stalePCArray = @()

# Filter to display the needed information. Note that it makes the CSV at the directory where the script is. Yes, I know it's a really complicated way to designate the directory. You can do it with .\ListOfPCs.csv
$stalePCs = Get-ADComputer -Filter {LastLogonTimeStamp -lt $stale_PC_Time} -Properties Name,Enabled,SamAccountName,LastLogon -ResultPageSize 1000 -ResultSetSize $null  | Select -Property Name,Enabled,SamAccountName,@{N='LastLogon_Time';E={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv -Path "$PSScriptRoot\StaleComputers.csv"

$stalePCArray += $stalePCs

```


---
### Stale AD Users
Description: Creates a CSV file with all users that have not checked in to
the domain in more than 90 days.

Must be run on Domain Controller.

```powershell
# Number of days you want to search for user inactivity
$days_User_Inactive = 90

$stale_User_Time = (Get-Date).AddDays(-($days_User_Inactive))

Get-ADUser -Filter {LastLogonDate -lt $stale_User_Time} -Properties Name,Enabled,SamAccountName,LastLogonTimeStamp -ResultPageSize 3000 -ResultSetSize $null  | Select -Property Name,Enabled,SamAccountName,@{N='LastLogon_Time';E={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv -Path "$PSScriptRoot\StaleUsers.csv"
```

---
### Create Basic AD Users from CSV
Description: Creates basic AD User objects from CSV. CSV must include First Name, Last Name, Department, and Username.

Must be run on Domain Controller.

```powershell
# Path to CSV with Employee Data. My example has 4 rows; First Name, Last Name, Department, and UserName
$PathToCSV = "<PathToCSV>\Employees.csv"

# Domain you're using for emails.
$emailDomain = "@domain.com"

# Loads CSV in to custom object CSVEmployee
$CSVEmployees = Import-Csv -Path $PathToCSV 

foreach($employee in $CSVEmployees) {

# Assigns variables in to 
$firstName = $employee.'First Name'

$lastName = $employee.'Last Name'

$department = $employee.Department

$userName = $employee.userName

$newUser = @{

Name = $userName

DisplayName = "$($firstName) $($lastName)"

Mail = "$($username)$($emailDomain)"

Enabled = $false

}

# New-ADUser $newUser

echo $newUser

}
```

---
### Hard match On-Prem user account to Entra
```powershell
# Must be run as admin. Use Powershell ISE for convenience.
# Step 1
# Run this first to install and import the following modules.
Install-Module MSOnline
Install-Module AzureAD
Import-Module AzureAD
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement

# Step 2
# Next Run the portion below.
# Will ask you for credentials to 
# connect to Microsoft Online Service.
# Run commands in the DC that has the Cloud Sync Agent.
Connect-ExchangeOnline
$Msolcred = Get-credential
Connect-MsolService -Credential $MsolCred

# Step 3
# Run this part.
# Get Local AD User GUID (Run these commands in the AD with Cloud Sync Agent).
$userAccount="<username>"
Get-ADUser $userAccount

# Step 4
# Run this.
$guid =(get-aduser $userAccount).objectGUID
$immutable =[System.convert]::ToBase64String($guid.tobytearray())
$guid
$immutable

# Step 5
# Finally, run this line AFTER filling out the UPN portion.
Set-MsolUser -UserPrincipalName <user@domain.com> -ImmutableID $immutable
```

---
### Re-run AD-Agent Sync
```powershell
Start-ADSyncSyncCycle -PolicyType initial
```

### Read a CSV
```powershell
$file = Import-Csv "Path\to\CSV.csv"

foreach ($item in $file) {

    Write-Host $item
    # Or to Run Command such as Disable Account:
    Disable-ADAccount -Identity $item

}
```

### Disable Computer Objects and Move to OU
```powershell
# This will disable all accounts listed in the CSV.

$file = Import-Csv "Path\To\CSV.csv"

# For loop iterates through the file
foreach ($item in $file) {

    # Used for Troubleshooting
    # Write-Host $item.SamAccountName
    # Disables the Computer Object then uses -PassThru and pipe to send to  Move-ADObject
    Disable-ADAccount -Identity $item.SamAccountName -PassThru | Move-ADObject -TargetPath "OU=FOR,DC=PC,DC=HERE"

}
```
---
### Enable Bitlocker and Manually Upload Key to AD
Description: This script can be left to run indefinitely with a scheduled task.

```powershell
$CdriveStatus = Get-BitLockerVolume -MountPoint $env:SystemDrive
if ($CdriveStatus.volumeStatus -eq 'FullyDecrypted') {
    C:\Windows\System32\manage-bde.exe -on c: -recoverypassword -skiphardwaretest
}
elseif ($CdriveStatus.volumeStatus -ne 'FullyDecrypted'){
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId (Get-BitLockerVolume -MountPoint "C:").KeyProtector[1].KeyProtectorId
}
```
---

## Run
---
This portion comes courtesy of user Joe Taylor from the [following StockExchange Post.](https://superuser.com/questions/217504/is-there-a-list-of-windows-special-directories-shortcuts-like-temp) Minor changes to the descriptions have been made.

### Windows Environment Path Variables
**%AllUsersProfile%** - Open the All User's Profile C:\ProgramData\ <br>
**%AppData%** - Opens AppData folder C:\Users\{username}\AppData\Roaming <br>
**%CommonProgramFiles%** - C:\Program Files\Common Files <br>
**%CommonProgramFiles(x86)%** - C:\Program Files (x86)\Common Files <br>
**%HomeDrive%** - Opens your home drive C:\ <br>
**%LocalAppData%** - Opens local AppData folder C:\Users\{username}\AppData\Local <br>
**%ProgramData%** - C:\ProgramData <br>
**%ProgramFiles%** - C:\Program Files or C:\Program Files (x86) <br>
**%ProgramFiles(x86)%** - C:\Program Files (x86) <br>
**%Public%** - C:\Users\Public <br>
**%SystemDrive%** - C: <br>
**%SystemRoot%** - Opens Windows folder C:\Windows <br>
**%Temp%** - Opens temporary file Folder C:\Users\{Username}\AppData\Local\Temp <br>
**%UserProfile%** - Opens your user's profile C:\Users\{username} <br>
**%AppData%\Microsoft\Windows\Start Menu\Programs\Startup** - Opens Windows 10 Startup location for program shortcuts <br>

### Run Commands
You can run any of the following with the <kbd>Win<\kbd>+<kbd>R<\kbd>.

**Calc** - Calculator <br>
**Cfgwiz32** - ISDN Configuration Wizard <br>
**Charmap** - Character Map <br>
**Chkdisk** - Repair damaged files <br>
**Cleanmgr** - Cleans up hard drives <br>
**Clipbrd** - Windows Clipboard viewer <br>
**Cmd** - Opens a new Command Window (cmd.exe) <br>
**Control** - Displays Control Panel <br>
**Dcomcnfg** - DCOM user security <br>
**Debug** - Assembly language programming tool <br>
**Defrag** - Defragmentation tool <br>
**Drwatson** - Records programs crash & snapshots <br>
**Dxdiag** - DirectX Diagnostic Utility <br>
**Explorer** - Windows Explorer <br>
**Fontview** - Graphical font viewer <br>
**Ftp** - ftp.exe program <br>
**Hostname** - Returns Computer's name <br>
**Ipconfig** - Displays IP configuration for all network adapters <br>
**Jview** - Microsoft Command-line Loader for Java classes <br>
**MMC** - Microsoft Management Console <br>
**Msconfig** - Configuration to edit startup files <br>
**Msinfo32** - Microsoft System Information Utility <br>
**Nbtstat** - Displays stats and current connections using NetBios over TCP/IP <br>
**Netstat** - Displays all active network connections <br>
**Nslookup** - Returns your local DNS server <br>
**Odbcad32** - ODBC Data Source Administrator <br>
**Ping** - Sends data to a specified host/IP <br>
**Regedit** - registry Editor <br>
**Regsvr32** - register/de-register DLL/OCX/ActiveX <br>
**Regwiz** - Registration wizard <br>
**Sfc /scannow** - System File Checker <br>
**Sndrec32** - Sound Recorder <br>
**Sndvol32** - Volume control for soundcard <br>
**Sysedit** - Edit system startup files (config.sys, autoexec.bat, win.ini, etc.) <br>
**Systeminfo** - display various system information in text console <br>
**Taskmgr** - Task manager <br>
**Telnet** - Telnet program <br>
**Taskkill** - kill processes using command line interface <br>
**Tskill** - reduced version of Taskkill from Windows XP Home <br>
**Tracert** - Traces and displays all paths required to reach an internet host <br>
**Winchat** - simple chat program for Windows networks <br>
**Winipcfg** - Displays IP configuration <br>

### Microsoft Office Suite
**winword** - Microsoft Word <br>
**excel** - Microsoft Excel <br>
**powerpnt** - Microsoft PowerPoint <br>
**msaccess** - Microsoft Access <br>
**outlook** - Microsoft Outlook <br>
**ois** - Microsoft Picture Manager <br>
**winproj** - Microsoft Project <br>

### Management Consoles
**certmgr.msc** - Certificate Manager <br>
**ciadv.msc** - Indexing Service <br>
**compmgmt.msc** - Computer management <br>
**devmgmt.msc** - Device Manager <br>
**dfrg.msc** - Defragment <br>
**diskmgmt.msc** - Disk Management <br>
**fsmgmt.msc** - Folder Sharing Management <br>
**eventvwr.msc** - Event Viewer <br>
**gpedit.msc** - Group Policy (< XP Pro) <br>
**iis.msc** - Internet Information Services <br>
**lusrmgr.msc** - Local Users and Groups <br>
**mscorcfg.msc** - Net configurations <br>
**ntmsmgr.msc** - Removable Storage <br>
**perfmon.msc** - Performance Manager <br>
**secpol.msc** - Local Security Policy <br>
**services.msc** - System Services <br>
**wmimgmt.msc** - Windows Management <br>

### Control Panel Utilities
**access.cpl** - Accessibility Options <br>
**hdwwiz.cpl** - Add New Hardware Wizard <br>
**appwiz.cpl** - Add/Remove Programs <br>
**timedate.cpl** - Date and Time Properties <br>
**desk.cpl** - Display Properties <br>
**inetcpl.cpl** - Internet Properties <br>
**joy.cpl** - Joystick Properties <br>
**main.cpl** keyboard - Keyboard Properties <br>
**main.cpl** - Mouse Properties <br>
**ncpa.cpl** - Network Connections <br>
**ncpl.cpl** - Network Properties <br>
**telephon.cpl** - Phone and Modem options <br>
**powercfg.cpl** - Power Management <br>
**intl.cpl** - Regional settings <br>
**mmsys.cpl** sounds - Sound Properties <br>
**mmsys.cpl** - Sounds and Audio Device Properties <br>
**sysdm.cpl** - System Properties. Useful if you want to change the domain or PC name. <br>
**nusrmgr.cpl** - User settings <br>
**firewall.cpl** - Firewall Settings (sp2) <br>
**wscui.cpl** - Security Center (sp2) <br>
**Wupdmgr** - Takes you to Microsoft Windows Update <br>
