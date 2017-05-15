# Set-Credentials

## Synopsis

Reads UserName from $UserNameFile and Password from $PasswordFile file

## Description

Function used to Get a System.Management.Automation.PSCredential object for use
with cmdlets that require credentials.

If there are files containing the User Name and an ecrypted Password the fuction
will use these files to create the credentials.

If the files cannot be found the script will prompt the user to enter credentials.

## Parameters

### UserNameFile

The path and name of the file which contains the User Name for the created credentials.
This parameter defaults to ./UserName.txt

### PasswordFile

The path and name of the file which contains the encrypted Password for the created credentials.
This parameter defaults to ./Password.txt

## Output

System.Management.Automation.PSCredential which can be used in with PS Remoting
