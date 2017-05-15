$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-Credentials" {
    #
    #  Tests where the User Name and Passwords cannot be extracted from files
    #  Default files cannot exist in test script folder for these tests
    #
    Context "Credentials Prompt Test" {
        # Can't Mock Get-Credential due to System.Management.Automation.CredentialAttribute.
        # Attribute is what causes prompt for credentials and Pester copies Parameter attributes 
        # so testing continues to prompt for credentials. Replacing Get-Credential cmdlet instead.
        function Get-Credential {
            return New-Object System.Management.Automation.PSCredential("TestUser", (ConvertTo-SecureString -AsPlainText -Force "TestPassword"))
        }
        
        It "No Parameters" {
            (Get-Credentials).UserName | Should Be "TestUser"
        }
    }

    #
    #  Tests "Files" parameter set
    #
    Context "Files Parameter Tests" {
        $userFile = "TestDrive:\UserName.txt"
        $passFile = "TestDrive:\Password.txt"

        $user = "UserNameFromFile"
        $pass = ConvertTo-SecureString -AsPlainText -Force "PasswordFilePassword"

        Set-Content $userFile -value $user
        Set-Content $passFile -value ($pass | ConvertFrom-SecureString)
        
        It "Parameters to files that don't exist" {
            { (Get-Credentials -UserNameFile "./NoUserNameFile.txt" -PasswordFile "./NoPasswordFile.txt") } | Should Throw
        }

        It "Parameters to files that exist" {
            (Get-Credentials -UserNameFile $userFile -PasswordFile $passFile).UserName | Should Be $user
        }

        Set-Content $passFile -value $pass

        It "Parameters to files that exist - with unencrypted password" {
            { Get-Credentials -UserNameFile $userFile -PasswordFile $passFile } | Should Throw
        }
    }

    #
    #  Tests where the User Name and Passwords are supplied directly by the call
    #
    Context "User Name Parameter Tests" {
        $user = "TestUser"
        $pass = "TestPassword"
        $securePass = $pass | ConvertTo-SecureString -AsPlainText -Force

        It "UserName and Password supplied" {
            (Get-Credentials -UserName $user -Password $pass).UserName | Should Be $user
        }

        It "UserName and Secure Password supplied" {
            (Get-Credentials -UserName $user -SecurePassword $securePass).UserName | Should Be $user
        }

        It "UserName supplied without the required Password or SecurePassword" {
            { (Get-Credentials -UserName $user) } | Should Throw
        }
    }
}
