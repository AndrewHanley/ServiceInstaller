$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-Credentials" {
    #
    #  Tests where the User Name and Passwords cannot be extracted from files
    #  Default files cannot exist in test script folder for these tests
    #
    Context "Credentials Prompt Tests" {
        # Can't Mock Get-Credential due to System.Management.Automation.CredentialAttribute.
        # Attribute is what causes prompt for credentials and Pester copies Parameter attributes 
        # so testing continues to prompt for credentials. Replacing Get-Credential cmdlet instead.
        function Get-Credential {
            return New-Object System.Management.Automation.PSCredential("TestUser", (ConvertTo-SecureString -AsPlainText -Force "TestPassword"))
        }
        
        It "No Parameters" {
            (Get-Credentials).UserName | Should Be "TestUser"
        }
        
        It "Parameters to files that don't exist" {
            (Get-Credentials -UserNameFile "./NoUserNameFile.txt" -PasswordFile "./NoPasswordFile.txt").UserName | Should Be "TestUser"
        }
    }

    #
    #  Tests where the User Name and Passwords can be extracted from files
    #
    Context "Credentials File Tests" {
        $userFile = "TestDrive:\UserName.txt"
        $passFile = "TestDrive:\Password.txt"

        $user = "UserNameFromFile"
        $pass = ConvertTo-SecureString -AsPlainText -Force "PasswordFilePassword"

        Set-Content $userFile -value $user
        Set-Content $passFile -value ($pass | ConvertFrom-SecureString)

        It "Parameters to files that exist" {
            (Get-Credentials -UserNameFile $userFile -PasswordFile $passFile).UserName | Should Be $user
        }

        Set-Content $passFile -value $pass

        It "Parameters to files that exist - with unencrypted password" {
            { Get-Credentials -UserNameFile $userFile -PasswordFile $passFile } | Should throw
        }
    }
}
