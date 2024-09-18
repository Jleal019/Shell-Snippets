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

## One-Liners
---


### Kills process by name or Process Id.
```powershell
Stop-Process -Name "<nameOfProcess>" -Id <PID>
```


### Shows currently running processes. Similar to top in Linux. Use with <name> to display attributes of specific process.
```powershell
Get-Process <name>
```


### Kills process forcefully by name. Primarily a CMD command.
```cmd
taskkill /f /fi "IMAGENAME eq TraCS.exe"
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

Remove-Item "%systemroot%\System32\spool\printers\*" -Confirm

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
$PathToCSV = "C:\Users\pditsupport\OneDrive - Sweetwater Police Department\Documents\Powershell\Employees.csv"

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
