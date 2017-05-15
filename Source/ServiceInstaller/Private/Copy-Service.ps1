<#
    .SYNOPSIS
    This function will copy the files from a source folder to a destination folder on a remote computer using the supplied credentials.
    If credentials are not supplied the copy will use the users current credentials for the copy

    .PARAMETER SourcePath      Path on computer executing script from which to copy files
    .PARAMETER DestinationPath UNC path on remote computer top copy files to
    .PARAMETER Credentials     Credentials to use when connecting to the remote server. 
#>
function Copy-ServiceToShare
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [pscredential]$Credentials
    )

    try 
    {
        $servDrive = "ServiceDrive"

        #Write-Output "Copying service files: `n `t Source: $local:sourcePath `n `t Destination: $local:destinationPath"

        if ($Credentials)
        {
            New-PSDrive -Name $servDrive -PSProvider "FileSystem" -Root $local:destinationPath -Credential $local:Credentials -ErrorAction Stop
        }
        else
        {
            New-PSDrive -Name $servDrive -PSProvider "FileSystem" -Root $local:destinationPath -ErrorAction Stop
        }

        Copy-Item `
            -Path "$local:sourcePath\*.*" `
            -Destination "$servDrive`:" `
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
    This function will copy the files from a source folder to a destination folder on a remote computer using an established PSSession

    .PARAMETER SourcePath      Path on computer executing script from which to copy files
    .PARAMETER DestinationPath UNC path on remote computer top copy files to
    .PARAMETER Session         Established PSSession with remote computer
#>
function Copy-ServiceToSession
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    Copy-Item `
        -Path "$local:sourcePath\*.*" `
        -Destination $DestinationPath `
        -Exclude "*.pdb", "*.txt" `
        -ToSession $Session `
        -Recurse `
        -ErrorAction Stop `
        -Force
}

<#
    .SYNOPSIS
    This function will copy the files from a source folder to a destination folder on a remote computer using the supplied credentials

    .PARAMETER sourcePath      Path on computer executing script from which to copy files
    .PARAMETER destinationPath UNC path on remote computer top copy files to
    .PARAMETER credentials     Credentials to use when connecting to the remote server
#>
function Copy-Service
{
    [CmdletBinding(DefaultParameterSetName="Share")]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("Source", "Src", "S")]
        [string]$SourcePath,

        [Parameter(Mandatory = $true, Position = 1)]
        [Alias("Destination", "Dest", "D")]
        [string]$DestinationPath,

        [Parameter(ParameterSetName="Share", Position = 2)]
        [Alias("Cred", "C")]
        [pscredential]$Credentials,

        [Parameter(ParameterSetName="Remoting", Mandatory = $true, Position = 2)]
        [Alias("Sess", "S")]
        [System.Management.Automation.Runspaces.PSSession]$Session
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        "Share" {
            Copy-ServiceToShare -SourcePath $SourcePath -DestinationPath $DestinationPath -Credentials $Credentials
        }

        "Remoting" {
            Copy-ServiceToSession -SourcePath $SourcePath -DestinationPath $DestinationPath -Session $Session
        }
    }
}
