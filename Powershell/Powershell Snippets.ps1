<#
----------------------------------------------------
Name: Blink NIC
Description: Script that asks for the name of the NIC you would like to enable and 
disable indefinitely. Useful if you're trying to track down a NIC port
on a switch.
Hit Ctrl+C to exit.

<!--Must be run as admin.--!>
----------------------------------------------------
#>

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

<#
----------------------------------------------------
Name: Stale Computers
Description: Creates a CSV file with all computers that have not checked in
to the domain in more than 120 days.

<!--Must be run in Domain Controller.--!>
----------------------------------------------------
#>

# Number of days you want to search for computer inactivity
$days_PC_Inactive = 120

# Converts $stale_PC_Time to $DaysInactive
$stale_PC_Time = (Get-Date).AddDays(-($days_PC_Inactive))

Get-ADComputer -Filter {LastLogonTimeStamp -lt $stale_PC_Time} -Properties Name,Enabled,LastLogon -ResultPageSize 1000 -ResultSetSize $null  | Select -Property Name,Enabled,@{N='LastLogon_Time';E={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv -Path "$PSScriptRoot\StaleComputers.csv"

<#
----------------------------------------------------
Name: Stale Computers
Description: Creates a CSV file with all users that have not checked in to
the domain in more than 90 days.

<!--Must be run in Domain Controller.--!>
----------------------------------------------------
#>

# Number of days you want to search for user inactivity
$days_User_Inactive = 90

$stale_User_Time = (Get-Date).AddDays(-($days_User_Inactive))

Get-ADUser -Filter {LastLogonDate -lt $stale_User_Time} -Properties Name,Enabled,LastLogonTimeStamp -ResultPageSize 3000 -ResultSetSize $null  | Select -Property Name,Enabled,@{N='LastLogon_Time';E={[DateTime]::FromFileTime($_.LastLogon)}} | Export-Csv -Path "$PSScriptRoot\StaleUsers.csv"