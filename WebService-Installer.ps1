<#
WEB service installer

Purpose:
    Install OSD WEB service and all its dependencies

Latest relase:  01/09/2019
Latest version: 0.1.5

Timeline:
    02/02/2019  -   v0.1.0  >   26/03/2019  -   v0.1.5  -   By Diagg/OSD-Couture.com
    01/09/2019  -   v0.1.5  >   ??/??/????  -   v?.?.?  -   By Ben Gibb https://github.com/BenGibb/OSD-Web-Service

History:
    02/02/2019  -   v0.1.0  -   Initial Release
    08/02/2019  -   v0.1.1  -   Added "run as a service feature" and credencials
    10/02/2019  -   v0.1.2  -   Added Scheduled task to ping the service
    08/03/2019  -   v0.1.3  -   Added credential validation by Jaap Brasser
    22/03/2019  -   v0.1.4  -   Removed unused features
                            -   Added firewall Rule
    26/03/2019  -   v0.1.5  -   The service now run in "above normal" priority
*   01/09/2019  -   v0.8.1  -   Fork from https://github.com/Diagg/OSD-Web-Service
                -   v0.8.2  -   Code cleanup and standardisation
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
[Int]$Port = 8550

# Functions
# TODO: Move all to external module
function Test-LocalCredential {
    [CmdletBinding()]
    Param (
        [string]
        $UserName,
        
        [string]
        $ComputerName = $env:COMPUTERNAME,
        
        [string]
        $Password
    )
    
    if (!($UserName) -or !($Password)) {
        Write-Warning 'Test-LocalCredential: Please specify both user name and password'
    }
    else {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $ComputerName)
        $DS.ValidateCredentials($UserName, $Password)
    }
}

function Test-ADCredential {
    [CmdletBinding()]
    Param (
        [string]
        $UserName,

        [string]
        $Password
    )

    if (!($UserName) -or !($Password)) {
        Write-Warning 'Test-ADCredential: Please specify both user name and password'
    }
    else {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
        $DS.ValidateCredentials($UserName, $Password)
    }
}

# Create folder for log file
$NewLog = "C:\ProgramData\MDT-Manager\$CurrentUser\Logs"
if (! (test-path $NewLog)) {
    New-Item -Path $NewLog -ItemType Directory -Force | out-null
    $testPath = Test-PathAndLog $NewLog -Action created
    if ($testPath -eq $false) {
        Write-ScriptEvent -value "[ERROR] Unable to create $NewLog, Aborting!!!!"
        exit
    }
}
else {
    Write-ScriptEvent -value "Path $NewLog already created, nothing to do !!!"
}

# Move log file to C:\ProgramData\MDT-Manager\Logs
$Script:LogFile = Move-Logging -path $NewLog
Write-ScriptEvent -value "New location for Logs is $Script:LogFile"

# Create folder Tools
# TODO: Move this to a Tools module
# TODO: Put list of tools into array/hash and fetch/process from that
$NewTools = "C:\ProgramData\MDT-Manager\Tools"
if (! (test-path $NewTools)) {
    New-Item -Path $NewTools -ItemType Directory -Force | out-null
    $testPath = Test-PathAndLog $NewTools -Action created
    if ($testPath -eq $false) {
        Write-ScriptEvent -value "[ERROR] Unable to create $NewTools, Aborting!!!!"
        exit
    }
}
else {
    Write-ScriptEvent -value "Path $NewTools already created, nothing to do !!!"
}

# Download NSSM
# TODO: Move this to a Tools module
# TODO: Combine $NewTools & Split $url path instead of hard coded names
$output = "$NewTools\nssm-2.24-101-g897c7ad\win64\nssm.exe"
if (!(Test-path $output)) {
    Write-ScriptEvent -value "Downloading NSSM to $output"
    $url = "https://nssm.cc/ci/nssm-2.24-101-g897c7ad.zip"
    # Start-BitsTransfer -Source $url -Destination $env:temp
    Invoke-BitsTransfer -Source $url -Destination $env:temp
    Expand-Archive -Path "$env:temp\nssm-2.24-101-g897c7ad.zip" -DestinationPath $NewTools
    $testPath = Test-PathAndLog $output
    if ($testPath -eq $false) {
        Write-ScriptEvent -value "[ERROR] Unable to download NSSM to folder $output, Please download and install the tool manually and retry, Aborting!!!!"
        exit
    }
}
else {
    Write-ScriptEvent -value "NSSM already downloaded, nothing to do !!!"
}

# Copy Files in C:\ProgramData\MDT-Manager\Tools Folder
# TODO: Move this to a Tools module
Write-ScriptEvent -value "Copying Scripts to $NewTools"
$ManagerFiles = @(
    'WebService-OSD.ps1'
    'DiaggFunctions.ps1'
    'WebService-Functions.ps1'
    'WebService-UnInstaller.ps1'
)
Foreach ($File in $ManagerFiles) {
    if (Test-Path "$Script:CurrentScriptPath\$File") {
        Copy-Item -Path "$Script:CurrentScriptPath\$File" -Destination $NewTools
    }
}

# Install AD Powershell Module
# TODO: Look up version of RSAT dynamically for future proofing
if ((Get-WmiObject -class Win32_OperatingSystem).caption -notlike '*server*') {
    if (!((Get-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0").State -eq 'Installed'))
    { Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" }
}
else {
    if (!((Get-WindowsFeature -Name "RSAT-ad-powershell").InstallState -eq 'Installed')) {
        Enable-WindowsOptionalFeature -Online -FeatureName RSAT-ADDS-Tools-Feature -ErrorAction SilentlyContinue
        Add-WindowsFeature -Name "RSAT-AD-AdminCenter" -IncludeAllSubFeature
        Add-WindowsFeature -Name "RSAT-AD-PowerShell" –IncludeAllSubFeature
    }
}
Import-Module activedirectory

# Get Account that will run the service
Write-ScriptEvent -value "Getting Credential for account used to run the service"
Do {
    #! This loop could run indefinately
    $creds = Get-Credential -Message "Enter Account with enought rights to run the service"
    $User = $creds.GetNetworkCredential().UserName
    $Pass = $creds.GetNetworkCredential().password
    $Dom = $creds.GetNetworkCredential().Domain
    if ((![string]::IsNullOrWhiteSpace($Dom)) -or ($Dom -ne $env:COMPUTERNAME)) {
        $TestCred = Test-ADCredential -UserName $User -Password $Pass
    }
    else {
        $TestCred = Test-LocalCredential -UserName $User -Password $Pass
    }
    if ($TestCred -eq $false) {
        Write-ScriptEvent -value "Unable to validate credential, please enter valid credential" -Severity 2
    }
} Until($TestCred -eq $true) #! This loop could run indefinately
Write-ScriptEvent -value "Credential Validated successfully"

if (![string]::IsNullOrWhiteSpace($Dom)) {
    $User = "$Dom\$User"
}

# Install Service
$nssm = $output
$serviceName = 'OSD-WEBService'
$powershell = (Get-Command powershell).Source
$scriptPath = "$NewTools\WebService-OSD.ps1"
$arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $scriptPath

if ((Get-Service $serviceName -ErrorAction SilentlyContinue).Name -eq $serviceName) {
    Write-ScriptEvent -value "Uninstalling previous version of the service"
    if ((Get-Service $serviceName).status -eq "Running") {
        Stop-Service $serviceName -Force -ErrorAction SilentlyContinue
    }
    if ((Get-Service $serviceName).status -eq "Stopped") {
        Write-ScriptEvent -value "Service $serviceName stopped successfully !!"
        $Cmd = Invoke-Executable -Path $nssm -Arguments "remove $serviceName confirm"
        if ($Cmd -match "service does not exist") {
            Write-ScriptEvent -value "Service $serviceName already uninstalled !!"
        }
    }
    else {
        Write-ScriptEvent -value "[ERROR] Unable to stop service $serviceName, Aborting!!!!"
        exit
    }
}

#! YUCK
Write-ScriptEvent -value "Registering WEB service"
& $nssm install $serviceName $powershell $arguments
Write-ScriptEvent -value "Adding service account"
$arguments = "ObjectName"
& $nssm set $serviceName $arguments $User $Pass
$arguments = "AppPriority" ; $Value = "BELOW_NORMAL_PRIORITY_CLASS"
& $nssm set $serviceName $arguments $Value
Write-ScriptEvent -value "Getting WEB service status:"
& $nssm status $serviceName
Write-ScriptEvent -value "Starting WEB service:"
Start-service $serviceName
Write-ScriptEvent -value "Starting New WEB service:"
Get-Service $serviceName
#! YUCK

# Create Firewall Rule for WebService
# TODO: Move to function in module
if ((Get-NetFirewallRule -DisplayName "OSD-WebService" -ErrorAction SilentlyContinue).DisplayName -eq "OSD-WebService") {
    Write-ScriptEvent -value "Uninstalling previous version of the Firewall Rules"
    Remove-NetFirewallRule -DisplayName "OSD-WebService" -Confirm:$false
    if (!((Get-NetFirewallRule -DisplayName "OSD-WebService" -ErrorAction SilentlyContinue).DisplayName -eq "OSD-WebService")) {
        Write-ScriptEvent -value "Firewall Rules uninstalled successfully !!"
    }
}
Write-ScriptEvent -value "Installing Firewall Rules"
# TODO: Move firewall rules to hashtable and splat
New-NetFirewallRule -Name "OSD-WebService" -DisplayName "OSD-WebService" -Description "OSDC - Quality Deployment since 1884" -Enabled True -Profile Domain, Private -Direction Inbound -Action Allow -LocalPort $Port -Protocol TCP -RemotePort Any | Out-Null

Write-ScriptEvent -value "Installation Finished !!!!"