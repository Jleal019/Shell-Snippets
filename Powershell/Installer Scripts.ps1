<#
----------------------------------------------------
Name: Install Script
Description: There's better ways to do this but here's a basic snippet to set up an
install Powershell script.
----------------------------------------------------
#>

# This line gets the current logged on users username.
$currentUser = ((Get-WmiObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]

<# 
Copies every item in the shortcuts directory to the users Desktop.
for this to work, the "Shortcuts" must be a directory where the script
is located.
#>
Copy-Item ".\Shortcuts\*" "C:\Users\$currentUser\Desktop\"

<# Writes to cli that a program is being installed. Useful to keep track of 
what is coming next in the installation.
#>
Write-Host "Installing Program..."

$process = (Start-Process -FilePath 'Installer.exe' -PassThru -Wait)

<# 
Pauses the script. Otherwise, if you have multiple installs in your script,
all will start up at the same time.
#>
$process.WaitForExit()

<# 
If installation process exits with 0, tells you the install was successful
else, tells you what the error code the installer exited with.
#>
if ($process.ExitCode -eq 0)
    {
        Write-Host "Installed successfully."
    }
else
    {
        # Tells you if the programs installer exited with an error code.
        Write-Host "Exited with code: " $process.ExitCode
    }

<#
----------------------------------------------------
Name: Uninstall/Version Upgrade
Description: This snippet is useful to uninstall a program. I've used it followed by
the previous Install Script snippet to upgrade a program version.
----------------------------------------------------
#>

#
if(Get-Package -Provider Programs -IncludeWindowsInstaller -Name "OldProgram *")
{
    Start-Process -FilePath "C:\Program Files (x86)\OldProgram\Uninstall.exe" -PassThru -Wait
}
else {
	Write-Host "OldProgram not detected."
}

<#
----------------------------------------------------
Name: Uninstall/Upgrade 2 Snippet
Description: A variation on the previous snippet. Checks if a OldProgram is installed.
If it's not, it installs NewProgram. If OldProgram is installed, it uninstalls
it and installs NewProgram.

I've used this to replace Office 2016 with Office 365.
----------------------------------------------------
#>

# $oldProgram should be the ProductName of the program.
$oldProgram = "OldProgramName" 

# Checks registry uninstallers for an occurrence of $oldProgram
$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -eq $oldProgram }) -ne $null

# If OldProgram is not installed, installs NewProgram.
If(-Not $installed) {
	Write-Host "OldProgram not detected..."
	Write-Host "Installing NewProgram..."

	$process = (Start-Process -FilePath '.\NewProgramSetup.exe' -PassThru -Wait) 

	$process.WaitForExit()

	if ($process.ExitCode -eq 0)
    	{
        	Write-Host "NewProgram installed successfully."
    	}
	else
    	{
        	Write-Host "NewProgram exited with code: " $process.ExitCode
    	}
# Else, uninstalls $oldProgram and asks you to restart PC.
} else {
	Write-Host "OldProgram detected, uninstalling..."
	$oldProgram.uninstall()
	Write-Host "OldProgram uninstalled, recommend restarting computer now."
}
