<#
    .SYNOPSIS
    This function will copy the files from a source folder to a destination folder on a remote computer using the supplied credentials

    .PARAMETER sourcePath      Path on computer executing script from which to copy files
    .PARAMETER destinationPath UNC path on remote computer top copy files to
    .PARAMETER credentials     Credentials to use when connecting to the remote server
#>
function Copy-Service
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias("source", "s")]
        [string]$sourcePath,

        [Parameter(Mandatory = $true, Position = 1)]
        [Alias("dest", "d")]
        [string]$destinationPath,

        [Parameter(Mandatory = $true, Position = 2)]
        [Alias("cred", "c")]
        [pscredential]$credentials
    )

    try 
    {
        $servDrive = "ServiceDrive"

        Write-Output "Copying service files: `n `t Source: $local:sourcePath `n `t Destination: $local:destinationPath"

        New-PSDrive -Name $servDrive -PSProvider "FileSystem" -Root $local:destinationPath -Credential $local:Credentials -ErrorAction Stop

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
