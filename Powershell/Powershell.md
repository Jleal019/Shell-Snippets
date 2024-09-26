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

III. [Active Directory Snippets](#active-directory-snippets)
<br>&nbsp; 1. [Stale AD Computers](#stale-ad-computers)
<br>&nbsp; 2. [Stale AD Users](#stale-ad-users)

IV. [Run](#run)

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


### Shows currently running processes. Similar to top in Linux. Use with <name> to display attributes of specific process.
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
$days_PC_Inactive = 120

# Converts $stale_PC_Time to $DaysInactive
$stale_PC_Time = (Get-Date).AddDays(-($days_PC_Inactive))

Get-ADComputer -Filter {LastLogonTimeStamp -lt $stale_PC_Time} -Properties Name,Enabled,LastLogon -ResultPageSize 1000 -ResultSetSize $null  | Select -Property Name,Enabled,@{N='LastLogon_Time';E={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv -Path "$PSScriptRoot\StaleComputers.csv"
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

Get-ADUser -Filter {LastLogonDate -lt $stale_User_Time} -Properties Name,Enabled,LastLogonTimeStamp -ResultPageSize 3000 -ResultSetSize $null  | Select -Property Name,Enabled,@{N='LastLogon_Time';E={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv -Path "$PSScriptRoot\StaleUsers.csv"

```powershell
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


## Run
---
This portion comes courtesy of user Joe Taylor from the [following StockExchange Post](https://superuser.com/questions/217504/is-there-a-list-of-windows-special-directories-shortcuts-like-temp) minor changes to the descriptionshave been made.


### Windows Environment Path Variables
```
*%AllUsersProfile%* - Open the All User's Profile C:\ProgramData
*%AppData%* - Opens AppData folder C:\Users\{username}\AppData\Roaming
*%CommonProgramFiles%* - C:\Program Files\Common Files
*%CommonProgramFiles(x86)%* - C:\Program Files (x86)\Common Files
*%HomeDrive%* - Opens your home drive C:\
*%LocalAppData%* - Opens local AppData folder C:\Users\{username}\AppData\Local
*%ProgramData%* - C:\ProgramData
*%ProgramFiles%* - C:\Program Files or C:\Program Files (x86)
*%ProgramFiles(x86)%* - C:\Program Files (x86)
*%Public%* - C:\Users\Public
*%SystemDrive%* - C:
*%SystemRoot%* - Opens Windows folder C:\Windows
*%Temp%* - Opens temporary file Folder C:\Users\{Username}\AppData\Local\Temp
*%UserProfile%* - Opens your user's profile C:\Users\{username}
*%AppData%\Microsoft\Windows\Start Menu\Programs\Startup* - Opens Windows 10 Startup location for program shortcuts
```




### Run commands
You can run any of the following with the <kbd>Win<\kbd>+<kbd>R<\kbd>.

```
*Calc* - Calculator
*Cfgwiz32* - ISDN Configuration Wizard
*Charmap* - Character Map
*Chkdisk* - Repair damaged files
*Cleanmgr* - Cleans up hard drives
*Clipbrd* - Windows Clipboard viewer
*Cmd* - Opens a new Command Window (cmd.exe)
*Control - Displays Control Panel
*Dcomcnfg* - DCOM user security
*Debug* - Assembly language programming tool
*Defrag* - Defragmentation tool
*Drwatson* - Records programs crash & snapshots
*Dxdiag* - DirectX Diagnostic Utility
*Explorer* - Windows Explorer
*Fontview* - Graphical font viewer
*Ftp* - ftp.exe program
*Hostname* - Returns Computer's name
*Ipconfig* - Displays IP configuration for all network adapters
*Jview* - Microsoft Command-line Loader for Java classes
*MMC* - Microsoft Management Console
*Msconfig* - Configuration to edit startup files
*Msinfo32* - Microsoft System Information Utility
*Nbtstat* - Displays stats and current connections using NetBios over TCP/IP
*Netstat* - Displays all active network connections
*Nslookup* - Returns your local DNS server
*Odbcad32* - ODBC Data Source Administrator
*Ping* - Sends data to a specified host/IP
*Regedit* - registry Editor
*Regsvr32* - register/de-register DLL/OCX/ActiveX
*Regwiz* - Registration wizard
*Sfc /scannow* - System File Checker
*Sndrec32* - Sound Recorder
*Sndvol32* - Volume control for soundcard
*Sysedit* - Edit system startup files (config.sys, autoexec.bat, win.ini, etc.)
*Systeminfo* - display various system information in text console
*Taskmgr* - Task manager
*Telnet* - Telnet program
*Taskkill* - kill processes using command line interface
*Tskill* - reduced version of Taskkill from Windows XP Home
*Tracert* - Traces and displays all paths required to reach an internet host
*Winchat* - simple chat program for Windows networks
*Winipcfg* - Displays IP configuration

### Microsoft Office suite
*winword* - Microsoft Word
*excel* - Microsoft Excel
*powerpnt* - Microsoft PowerPoint
*msaccess* - Microsoft Access
*outlook* - Microsoft Outlook
*ois* - Microsoft Picture Manager
*winproj* - Microsoft Project
```


### Management Consoles
```
*certmgr.msc* - Certificate Manager
*ciadv.msc* - Indexing Service
*compmgmt.msc* - Computer management
*devmgmt.msc* - Device Manager
*dfrg.msc* - Defragment
*diskmgmt.msc* - Disk Management
*fsmgmt.msc* - Folder Sharing Management
*eventvwr.msc* - Event Viewer
*gpedit.msc* - Group Policy (< XP Pro)
*iis.msc* - Internet Information Services
*lusrmgr.msc* - Local Users and Groups
*mscorcfg.msc* - Net configurations
*ntmsmgr.msc* - Removable Storage
*perfmon.msc* - Performance Manager
*secpol.msc* - Local Security Policy
*services.msc* - System Services
*wmimgmt.msc* - Windows Management
```


### Control Panel utilities
```
*access.cpl* - Accessibility Options
*hdwwiz.cpl* - Add New Hardware Wizard
*appwiz.cpl* - Add/Remove Programs
*timedate.cpl* - Date and Time Properties
*desk.cpl* - Display Properties
*inetcpl.cpl* - Internet Properties
*joy.cpl* - Joystick Properties
*main.cpl* keyboard - Keyboard Properties
*main.cpl* - Mouse Properties
*ncpa.cpl* - Network Connections
*ncpl.cpl* - Network Properties
*telephon.cpl* - Phone and Modem options
*powercfg.cpl* - Power Management
*intl.cpl* - Regional settings
*mmsys.cpl* sounds - Sound Properties
*mmsys.cpl* - Sounds and Audio Device Properties
*sysdm.cpl* - System Properties. Useful if you want to change the domain or PC name.
*nusrmgr.cpl* - User settings
*firewall.cpl* - Firewall Settings (sp2)
*wscui.cpl* - Security Center (sp2)
*Wupdmgr* - Takes you to Microsoft Windows Update
```
