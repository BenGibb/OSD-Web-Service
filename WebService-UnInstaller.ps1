<#
WEB service uninstaller

Purpose:
    Uninstall OSD WEB service and all its dependencies

Latest relase:  01/09/2019
Latest version: 0.2.0

Timeline:
    18/03/2019  -   v0.1.0  >   26/03/2019  -   v0.2.0  -   By Diagg/OSD-Couture.com
    01/09/2019  -   v0.2.0  >   ??/??/????  -   v?.?.?  -   By Ben Gibb https://github.com/BenGibb/OSD-Web-Service

History:
    18/03/2019  -   v0.1.0  -   Initial Release
    26/03/2019  -   v0.2.0  -   Added try/Cacth when shuting down the service
*   01/09/2019  -   v0.2.0  -   Fork from https://github.com/Diagg/OSD-Web-Service
                -   v0.2.1  -   Code cleanup and standardisation
#>

#Requires -Version 4
#Requires -RunAsAdministrator

Clear-Host
# Debug
$ErrorActionPreference = "stop"
#$ErrorActionPreference = "Continue"

# Global Variables
$Script:CurrentScriptName = $MyInvocation.MyCommand.Name
$Script:CurrentScriptFullName = $MyInvocation.MyCommand.Path
$Script:CurrentScriptPath = split-path $MyInvocation.MyCommand.Path

# Init Script
."$CurrentScriptPath\DiaggFunctions.ps1" # TODO: Move to modules
$CurrentUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name).split("\")[1]
$Script:LogFile = Initialize-Logging

# UnInstall Service
$NewTools = "C:\ProgramData\MDT-Manager\Tools"
$nssm = "$NewTools\nssm-2.24-101-g897c7ad\win64\nssm.exe"
$serviceName = 'OSD-WEBService'
# $powershell = (Get-Command powershell).Source
$scriptPath = "$NewTools\WebService-OSD.ps1"
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath
Write-ScriptEvent -value "Uninstalling OSD Web service !!"

if ((Get-Service $serviceName -ErrorAction SilentlyContinue).Name -eq $serviceName) {
    # Closing Web Service
    Writes-ScriptEvent -value "Stopping web server !!"
    Try {
        Invoke-WebRequest -Uri "http://$($env:computername):8530/OSDInfo?command=Exit" -ErrorAction SilentlyContinue | Out-Null
    }
    Catch {
        if ($error[0] -like "*404.0*") {
            Writes-ScriptEvent -value "Web server stopped successfully!!"
        }
    }
    Writes-ScriptEvent -value "Stopping Windows service"
    if ((Get-Service $serviceName).status -ne "Stopped") {
        Stop-Service $serviceName -Force -ErrorAction SilentlyContinue
    }
    if ((Get-Service $serviceName).status -eq "Stopped") {
        Writes-ScriptEvent -value "Service $serviceName stopped successfully !!"
        Writes-ScriptEvent -value "Uninstalling NSSM service"
        $Cmd = Invoke-Executable -Path $nssm -Arguments "remove $serviceName confirm"
        if ($Cmd -match "service does not exist") {
            Writes-ScriptEvent -value "Service $serviceName already uninstalled !!"
        }
    }
    else {
        Writes-ScriptEvent -value "[ERROR] Unable to stop service $serviceName, Aborting!!!!"
        exit
    }
}

# Schedule task to ping WEB service evry 5 minutes
$TaskName = "Ping OSD WEB Service"
if ([string]::IsNullOrWhiteSpace($(Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue).State)) {
    Writes-ScriptEvent -value "Uninstalling Scheduled task"
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$False
}
else {
    Writes-ScriptEvent -value "Scheduled task already uninstalled !!"
}

# Remove Firewal Rule
if ((Get-NetFirewallRule -DisplayName "OSD-WebService" -ErrorAction SilentlyContinue).DisplayName -eq "OSD-WebService") {
    Writes-ScriptEvent -value "Removing Firewall Execption"
    Remove-NetFirewallRule -DisplayName "OSD-WebService" -Confirm:$false
}
else {
    Writes-ScriptEvent -value "Firewall Execption already uninstalled !!"
}

# Delete all Files
Writes-ScriptEvent -value "Removing remaining files !!"
Remove-item -path $NewTools -Recurse -Force -ErrorAction SilentlyContinue

# The end my friend
Writes-ScriptEvent -value "OSD WEB Service Uninstallation finished !!"
