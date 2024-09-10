<#
----------------------------------------------------
Name: Clear Spoolers
Description: Clears out the print spooler. Helpful if there are stuck print jobs.
<!--Must be run as admin.--!>
----------------------------------------------------
#>

net stop spooler

Remove-Item "%systemroot%\System32\spool\printers\*" -Confirm

net start spooler

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

<#
----------------------------------------------------
Name: Create Basic AD Users from CSV
Description: Creates basic AD User objects from CSV. CSV must include First Name, Last Name, Department, and Username.
<!--Must be run in Domain Controller.--!>
----------------------------------------------------
#>
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


# Unblock the following snippet to get it running

$newUser = @{

Name = $userName

DisplayName = "$($firstName) $($lastName)"

Mail = "$($username)$($emailDomain)"

Enabled = $false

}

# New-ADUser $newUser

echo $newUser

}


