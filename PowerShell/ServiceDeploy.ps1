<#
    .SYNOPSIS
    This script is used to deploy services to a remote computer

    .PARAMETER Environment
    Parameter identifies the intended target environment on which to run the service

    .PARAMETER Uninstall
    Supplying this parameter will add an Uninstall step into the service deployment if the service is installed

    .NOTES
    Originally used Return statement in some functions. When a statement like $result = GET-FUNC is written
    ALL output is collected into an array and returned not just the variable specfied. For example;
    function()
    {
        Write-Output "Hello World"
        return "Result"
    }
    Will return
        Hello World
        Result

    To address the return statement issue functions that are expected to return data now do so through the use
    of By Reference Parameters. See Search-Environment for implementation details
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

    .PARAMETER retValue
    Returns the name of the remote server based upon the Environment supplied
#>
function Search-Environment (
        [string]$environment = $(throw "Set-Credentials: environment is required"),
        [ref]$retValue
)
{
    $local:environment = $environment.ToUpper()
    $local:validEnvironments = "DEBUG","UAT","PROD"

    Write-Output "Verifying $local:environment is a valid solution environment"

    if (!$local:validEnvironments.Contains($local:environment))
    {
        $(throw "Invalid Environment. Valid values include 'Debug', 'UAT' and 'Prod'")
    }

    switch ($local:environment)
    {
        "DEBUG" { $retValue.Value = "VM-Remote" }
        "UAT"   { $retValue.Value = "VM-Remote-UAT"   }
        "PROD"  { $retValue.Value = "VM-Remote-Prod"  }
    }

    #Write-Verbose "Remote server set to $retValue"
}

<#
    .SYNOPSIS
    Reads UserName from UserName.txt file and Password from Password.txt file

    .OUTPUTS
    System.Management.Automation.PSCredential which can be used in with PS Remoting
#>
function Set-Credentials (
    [ref]$retVal
)
{
    Write-Output "Setting user credentials for deployment"

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

    $retVal.Value = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $local:user, $local:pass
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
            -ErrorAction Stop `
            -Force
    }
    catch [System.ComponentModel.Win32Exception]
    {
        $(throw "Unable to connect to $local:destinationPath. Make sure you do not have a remote connection to the folder.")
    }
    catch [System.IO.IOException]
    {
        $(throw "Unable to copy files to $local:destinationPath. `n `t $_ `n")
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
$ServerName = ""

Search-Environment -environment $Environment -retValue ([ref]$ServerName)
Set-Credentials -retVal ([ref]$Credentials)

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
