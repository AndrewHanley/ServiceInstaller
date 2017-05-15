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
    [CmdletBinding(DefaultParameterSetName="NoParams")]
    param 
    (
        [Parameter(ParameterSetName="Files", Position = 0)]
        [Alias("UserFile", "UF")]
        [string]$UserNameFile,

        [Parameter(ParameterSetName="Files", Position = 1)]
        [Alias("PassFile", "PF")]
        [string]$PasswordFile,

        [Parameter(ParameterSetName="UserNamePassword", Mandatory = $true, Position = 0)]
        [Parameter(ParameterSetName="UserNameEncryptedPassword", Mandatory = $true, Position = 0)]
        [Alias("User", "U")]
        [string]$UserName,

        [Parameter(ParameterSetName="UserNamePassword", Mandatory = $true, Position = 1)]
        [Alias("Pass", "P")]
        [string]$Password,

        [Parameter(ParameterSetName="UserNameEncryptedPassword", Mandatory = $true, Position = 1)]
        [Alias("SecurePass", "SecPass", "SPass", "SP")]
        [securestring]$SecurePassword
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        "NoParams" {
            $local:tmpCred = Get-Credential
            $local:user = $local:tmpCred.UserName
            $local:pass = $local:tmpCred.Password
        }

        "Files" {
            if (!(Test-Path $UserNameFile) -Or !(Test-Path $PasswordFile))
            {
                Throw [System.IO.FileNotFoundException] "$UserNameFile or $PasswordFile not found."
            }
            Else
            {
                $local:user = Get-Content $UserNameFile
                $local:pass = Get-Content $PasswordFile  | ConvertTo-SecureString
            }
        }

        "UserNamePassword" {
            $local:user = $UserName
            $local:pass = $Password | ConvertTo-SecureString -AsPlainText -Force
        }

        "UserNameEncryptedPassword" {
            $local:user = $UserName
            $local:pass = $SecurePassword
        }
    }

    return New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $local:user, $local:pass
}
