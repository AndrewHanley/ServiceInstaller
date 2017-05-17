$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Copy-Service" {
    $source = "TestDrive:\Source"
    $destination = "TestDrive:\Destination"
    $user = "TestUser"
    $password = ConvertTo-SecureString -AsPlainText -Force "TestPassword"
    $credentials = New-Object System.Management.Automation.PSCredential($user, $password)

    New-Item $source -ItemType Directory
    New-Item $destination -ItemType Directory
    
    Set-Content "$source\Service.exe" -Value "Service Content"
    Set-Content "$source\Service.exe.Config" -Value "Service Config Content"
    Set-Content "$source\Test.txt" -Value "Text File for Exlusion Testing"
    Set-Content "$source\Test.pdb" -Value "PDB File for Exlusion Testing"

    Context "Test Setup Tests" {
        It "Source Folder Exists" {
            (Test-Path $source) | Should Be $true
        }

        It "Destination Folder Exists" {
            (Test-Path $destination) | Should Be $true
        }

        It "Source Files Exists" {
            (Get-ChildItem $source).Count | Should Be 4
        }
    }

    Context "Share Copy Tests" {
        It "With Credentials" {
            Remove-Item "$destination\*" -Recurse
            Copy-Service -SourcePath $source -DestinationPath $destination -Credentials $credentials
            (Get-ChildItem $destination).Count | Should Be 2
        }

        It "Without Credentials" {
            Remove-Item "$destination\*" -Recurse
            Copy-Service -SourcePath $source -DestinationPath $destination
            (Get-ChildItem $destination).Count | Should Be 2
        }
    }

    <#
        This Test Requires the PS Session in which it is running to be "Run As Administrator"
        Even with credentials supplied connecting to LocalHost requires admin
    #>
    Context "PS Remoting Copy Tests" {
        $remoteDest = "C:\PesterTestTemp"
        New-Item $remoteDest -ItemType Directory    

        $session = New-PSSession LocalHost

        It "Files Copied" {
            Copy-Service -SourcePath $source -DestinationPath $remoteDest -Session $session
            (Get-ChildItem $remoteDest).Count | Should Be 2
        }

        Remove-PSSession $session

        Remove-Item $remoteDest -Recurse
    }
}
