<#
    .SYNOPSIS
    This script is used to deploy services to a remote computer

    .PARAMETER environment
    Parameter identifies the intended target environment on which to run the service

    .PARAMETER Uninstall
    Supplying this parameter will add an Uninstall step into the service deployment if the service is installed
#>
Param (
    [Parameter(Mandatory=$True)]
    [Alias("env")]
    [string]$Environment,
    [Alias("u")]
    [switch]$Uninstall
)

<#
    .SYNOPSIS
    Verifies the environment passed into the script is valid for the project

    .PARAMETER env
    Environment value to verify as an acceptable value
#>
function Search-Environment (
    [string]$env = $(throw "Verify-Envronment: env is required")
)
{
    Write-Verbose "Verifying supplied environment is a valid solution environment"

    $validEnvironments = "DEBUG","UAT","PROD"

    if (!$validEnvironments.Contains($env.ToUpper()))
    {
        Write-Error "Invalid Environment. Valid values include 'Debug', 'UAT' and 'Prod'"
        exit
    }
}

<#
    .SYNOPSIS
    Reads UserName from UserName.txt file and Password from Password.txt file

    .OUTPUTS
    System.Management.Automation.PSCredential which can be used in with PS Remoting
#>
function Set-Credentials ()
{
    $user = Get-Content "UserName.txt"
    $pass = Get-Content "Password.txt"  | ConvertTo-SecureString

    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pass
}

#
# If service doesn't exist on server, it is installed using Install Util
#
function Install-Service (
    [string]$serviceName = $(throw "Install-Service: serviceName is required"),
    [string]$servicePath = $(throw "Install-Service: servicePath is required"),
    [string]$targetServer = $(throw "Install-Service: targetServer is required"),
    [pscredential]$credentials = $(throw "Install-Service: credentials are required"))
{
    Write-Verbose "Install-Service: Get-Service for $serviceName service on $targetServer"
    
    #$service = Get-Service -ComputerName $targetServer -Name $serviceName -ErrorAction SilentlyContinue
    $service = Get-Service -ComputerName $targetServer -Name $serviceName

    if (!($service))
    {
        Write-Output "Installing Service $serviceName on $targetServer..."
        Invoke-Command `
            -ComputerName $targetServer `
            -Credential $credentials `
            -ScriptBlock { C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /install "$servicePath" }
    }
}


#
# Uninstalls service on remote server
#
function Uninstall-Service (
    [string]$serviceName = $(throw "Uninstall-Service: serviceName is required"),
    [string]$servicePath = $(throw "Uninstall-Service: servicePath is required"),
    [string]$targetServer = $(throw "Uninstall-Service: targetServer is required"),
    [pscredential]$credentials = $(throw "Uninstall-Service: credentials are required"))
{
    Write-Verbose "Uninstalling service if requested through the -Uninstall parameter"
    
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

    if ($service)
    {
        Write-Output "Uninstalling Service..."
        Invoke-Command `
            -ComputerName $targetServer `
            -Credential $credentials `
            -ScriptBlock { C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /uninstall "$servicePath" }
    }
}

Search-Environment -env $Environment

$serverName = "VM-Remote"
$cred = Set-Credentials

$projectPath = "C:\Projects\ServiceInstaller\WindowsService\"

$executableName = "TestingService"
$servicePath = Join-Path -Path $projectPath -ChildPath "$serviceName\bin\$Environment\$serviceName.exe"

Write-Verbose "ServicePath: $servicePath"

if ($Uninstall)
{
    Uninstall-Service -serviceName $serviceName -servicePath $servicePath -targetServer $serverName -credentials $cred
}

$log = Install-Service -serviceName $serviceName -servicePath $servicePath -targetServer $serverName -credentials $cred

Write-Output $log
