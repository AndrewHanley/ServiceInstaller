<#
    .SYNOPSIS
    Reads UserName from $UserNameFile and Password from $PasswordFile file

    .DESCRIPTION
    Function used to Get a System.Management.Automation.PSCredential object for use
    with cmdlets that require credentials.

    If there are files containing the User Name and an ecrypted Password the fuction
    will use these files to create the credentials.

    If the files cannot be found the script will prompt the user to enter credentials.

    .PARAMETER UserNameFile
    The path and name of the file which contains the User Name for the created credentials.
    This parameter defaults to ./UserName.txt

    .PARAMETER PasswrodFile
    The path and name of the file which contains the encrypted Password for the created credentials.
    This parameter defaults to ./Password.txt

    .OUTPUTS
    System.Management.Automation.PSCredential which can be used in with PS Remoting
#>
function Get-Credentials 
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Position = 0)]
        [Alias("user", "u")]
        [string]$UserNameFile = "./UserName.txt",

        [Parameter(Position = 1)]
        [Alias("pass", "p")]
        [string]$PasswordFile = "./Password.txt"
    )

    if (!(Test-Path $UserNameFile) -Or !(Test-Path $PasswordFile))
    {
        $local:tmpCred = Get-Credential
        $local:user = $local:tmpCred.UserName
        $local:pass = $local:tmpCred.Password
    }
    Else
    {
        $local:user = Get-Content $UserNameFile
        $local:pass = Get-Content $PasswordFile  | ConvertTo-SecureString
    }

    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $local:user, $local:pass
}
