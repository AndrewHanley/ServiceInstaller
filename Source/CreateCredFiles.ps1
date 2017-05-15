<#
    .SYNOPSIS
    This script is used to create UserName and Password Credential files on a computer that can be used in other scripts

    .PARAMETER Path
    Path generated file will be created in, defaults to current path
#>
Param(
    [string]$Path = ".\"
)

#
# Prompt user to enter credentials to store
#
$cred = Get-Credential

#
# Save UserName into UserName.txt file in location specified
#
$fileName = Join-Path -Path $Path -ChildPath "UserName.txt"
Set-Content $fileName $cred.UserName -Force

#
# Save Encrypted Password into Password.txt file in location specified
#
$secureStringText = $cred.Password | ConvertFrom-SecureString
$fileName = Join-Path -Path $Path -ChildPath "Password.txt"
Set-Content $fileName $secureStringText -Force
