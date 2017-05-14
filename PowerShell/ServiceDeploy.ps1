<#
    .SYNOPSIS
    This script is used to deploy services to a remote computer

    .PARAMETER Environment
    Parameter identifies the intended target environment on which to run the service

    .PARAMETER Uninstall
    Supplying this parameter will add an Uninstall step into the service deployment if the service is installed

    .NOTES
    Error messages in script are written to Console with Write-Host. This is to allow colored messages without including
    stack traces, etc. This is NOT a great approach as it will cause issues if the script isn't run from a console.
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

    .PARAMETER environment
    Environment value to verify as an acceptable value

    .OUTPUTS
    Returns the name of the remote server based upon the Environment supplied
#>
function Search-Environment (
        [string]$environment = $(throw "Set-Credentials: environment is required")
)
{
    $local:environment = $environment.ToUpper()
    $local:validEnvironments = "DEBUG","UAT","PROD"

    Write-Output "Verifying $local:environment is a valid solution environment"

    if (!$local:validEnvironments.Contains($local:environment))
    {
        Write-Host "Invalid Environment. Valid values include 'Debug', 'UAT' and 'Prod'" -ForegroundColor Red
        Break
    }

    switch ($local:environment)
    {
        "DEBUG" { $local:serverName = "VM-Remote" }
        "UAT"   { $local:serverName = "VM-Remote-UAT"   }
        "PROD"  { $local:serverName = "VM-Remote-Prod"  }
    }

    Write-Verbose "Remote server set to $local:serverName"

    return $local:serverName
}

<#
    .SYNOPSIS
    Reads UserName from UserName.txt file and Password from Password.txt file

    .OUTPUTS
    System.Management.Automation.PSCredential which can be used in with PS Remoting
#>
function Set-Credentials (
)
{
    Write-Verbose "Setting user credentials for deployment"

    if (!(Test-Path "UserName.txt") -Or !(Test-Path "Password.txt"))
    {
        Write-Verbose "Credential files not found"
    
        $local:tmpCred = Get-Credential
        $local:user = $local:tmpCred.UserName
        $local:pass = $local:tmpCred.Password
    }
    Else
    {
        Write-Verbose "Credential files found"
    
        $local:user = Get-Content "UserName.txt"
        $local:pass = Get-Content "Password.txt"  | ConvertTo-SecureString
    }

    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $local:user, $local:pass
}

<#
    .SYNOPSIS
    This function will copy the files from a source folder to a destination folder on a remote computer using the supplied credentials

    .PARAMETER sourcePath      Path on computer executing script from which to copy files
    .PARAMETER destinationPath UNC path on remote computer top copy files to
    .PARAMETER credentials     Credentials to use when connecting to the remote server
#>
function Copy-Service(
    [string]$sourcePath = $(throw "Copy-Service: sourcePath is required"),
    [string]$destinationPath = $(throw "Copy-Service: sourcePath is required"),
    [pscredential]$credentials = $(throw "Copy-Service: credentials are required"))
{
    try 
    {
        Write-Output "Copying service files: `n `t Source: $local:sourcePath `n `t Destination: $local:destinationPath"

        New-PSDrive -Name "PSDrive" -PSProvider "FileSystem" -Root $local:destinationPath -Credential $local:Credentials -ErrorAction Stop

        Copy-Item `
            -Path "$local:sourcePath\*.*" `
            -Destination "PSDrive:" `
            -Exclude "*.pdb", "*.txt" `
            -Recurse `
            -Force
    }
    catch [System.ComponentModel.Win32Exception]
    {
        Write-Host "Unable to connect to $destinationPath. Make sure you do not have a remote connection to the folder." -ForegroundColor Red
        Break
    }
}

<#
    .SYNOPSIS
    If service doesn't exist on server, it is installed using InstallUtil

    .PARAMETER serviceName  Name of service to install
    .PARAMETER servicePath  Path, including executable name, for the service on the remote machine
    .PARAMETER targetServer Name of server to install the service on
    .PARAMETER credentials  Credentials to use when connecting to the remote server
#>
function Install-Service (
    [string]$serviceName = $(throw "Install-Service: serviceName is required"),
    [string]$servicePath = $(throw "Install-Service: servicePath is required"),
    [string]$targetServer = $(throw "Install-Service: targetServer is required"),
    [pscredential]$credentials = $(throw "Install-Service: credentials are required"))
{
    Write-Verbose "Install-Service: Get-Service for $local:serviceName service on $local:targetServer"
    
    $service = Get-Service -ComputerName $local:targetServer -Name $local:serviceName -ErrorAction SilentlyContinue

    if (!($service))
    {
        Write-Output "Installing Service $local:serviceName on $local:targetServer..."
        Invoke-Command `
            -ComputerName $local:targetServer `
            -Credential $local:credentials `
            -ScriptBlock { C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /install "$local:servicePath" }
    }
}


<#
    .SYNOPSIS
    Uninstalls service on remote server if it is installed

    .PARAMETER serviceName  Name of service to uninstall
    .PARAMETER servicePath  Path, including executable name, for the service on the remote machine
    .PARAMETER targetServer Name of server to uninstall the service on
    .PARAMETER credentials  Credentials to use when connecting to the remote server
#>
function Uninstall-Service (
    [string]$serviceName = $(throw "Uninstall-Service: serviceName is required"),
    [string]$servicePath = $(throw "Uninstall-Service: servicePath is required"),
    [string]$targetServer = $(throw "Uninstall-Service: targetServer is required"),
    [pscredential]$credentials = $(throw "Uninstall-Service: credentials are required"))
{
    Write-Verbose "Uninstalling service if requested through the -Uninstall parameter"
    
    $service = Get-Service -Name $local:serviceName -ErrorAction SilentlyContinue

    if ($service)
    {
        Write-Output "Uninstalling Service..."
        Invoke-Command `
            -ComputerName $local:targetServer `
            -Credential $local:credentials `
            -ScriptBlock { C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /uninstall "$local:servicePath" }
    }
}

#
# Main Script Execution Point
#
$ServerName = Search-Environment -environment $Environment
$Credentials = Set-Credentials

$ServiceName = "TestService"

# Build file paths
$SourcePath = Join-Path -Path "C:\Projects\ServiceInstaller\WindowsService\" -ChildPath "$ServiceName\bin\$Environment\"
$DestinationPath = "\\$ServerName\Service"

#
# Display Variables
#
Write-Verbose "Server Name: $ServerName"
Write-Verbose "Service Name: $ServiceName"
Write-Verbose "Source Path: $SourcePath"
Write-Verbose "Destination Path: $DestinationPath"

Copy-Service -sourcePath $SourcePath -destinationPath $DestinationPath -credentials $Credentials

if ($Uninstall)
{
    Uninstall-Service -serviceName $serviceName -servicePath $servicePath -targetServer $ServerName -credentials $Credentials
}

#$log = Install-Service -serviceName $serviceName -servicePath $servicePath -targetServer $ServerName -credentials $Credentials

#Write-Output $log
