. "../Private/Copy-Service.ps1"
. "../Private/Get-Configuration.ps1"
. "../Private/Get-Credentials.ps1"
. "../Private/InstallUninstall-Service.ps1"

function Deploy-Service
{
    [CmdletBinding(DefaultParameterSetName="NoParams")]
    param
    (        
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("Server")]
        [string]$ServerName,

        [Parameter(Mandatory = $true, Position = 1)]
        [Alias("Service")]
        [string]$ServiceName,

        [Parameter(Mandatory = $true, Position = 2)]
        [Alias("Path")]
        [string]$ServicePath,

        [Parameter(Mandatory = $true, Position = 3)]
        [Alias("Remote")]
        [string]$RemotePath,

        [Parameter(ParameterSetName="UserNamePassword", Mandatory = $true, Position = 4)]
        [Parameter(ParameterSetName="UserNameEncryptedPassword", Mandatory = $true, Position = 4)]
        [Alias("User", "U")]
        [string]$UserName,

        [Parameter(ParameterSetName="UserNamePassword", Mandatory = $true, Position = 5)]
        [Alias("Pass", "P")]
        [string]$Password,

        [Parameter(ParameterSetName="UserNameEncryptedPassword", Mandatory = $true, Position = 5)]
        [Alias("SecurePass", "SecPass", "SPass", "SP")]
        [securestring]$SecurePassword
    )

    Write-Output "Get Deployment Configuration"
    $Config = Get-Configuration

    Write-Output "Resolve Security Credentials"
    $Credentials = Resolve-Credentials -UserName $UserName -Password $Password -SecurePassword $SecurePassword -ConfigCredentials $Config.Credentials

    Write-Output "Create Remote Server Session"
    $Session = New-PSSession -ComputerName $ServerName #-Credential $Credentials

    try 
    { 
        Write-Output "Stopping service"
        Invoke-Command `
            -Session $Session `
            -ScriptBlock { Stop-Service `"$($args[0])`" } `
            -ArgumentList $ServiceName `
            -ErrorAction SilentlyContinue

        Write-Output "Transferring Service Files To Server"
        Copy-Service -SourcePath $ServicePath -DestinationPath $RemotePath -Session $Session

        Write-Output "Installing Service"
        Install-Service -ServiceName $ServiceName -ServicePath (Join-Path -Path $RemotePath -ChildPath "TestService.exe") -Session $Session

        Write-Output "Starting Service"
        Invoke-Command `
            -Session $Session `
            -ScriptBlock { Start-Service `"$($args[0])`" } `
            -ArgumentList $ServiceName `
            -ErrorAction SilentlyContinue
    }
    finally
    {
        Remove-PSSession $Session
    }
}

Deploy-Service -ServerName VM-SERVER-DEBUG -ServiceName TestingService -ServicePath "C:\Projects\Service" -RemotePath "C:\Services"