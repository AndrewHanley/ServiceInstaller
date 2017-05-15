$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-Configuration" {
    It "Using Default Parameters - File Not Found" {
        { Get-Configuration } | Should Throw
    }

    It "Using Invalid File Parameter - File Not Found" {
        { Get-Configuration -ConfigFile "NoFile.json" } | Should Throw
    }

    <#
        Following test displays exception and fails test
        Exception was expected but should be trapped in test
        
    It "Using Non-Json Config File" {
        $badConfigFile = "TestDrive:\BadConfig.json"
        Set-Content $badConfigFile -Value "NOT JSON"

        { Get-Configuration -ConfigFile $badConfigFile } | Should Throw
    }
    #>

    Context "Valid Configuration File Tests" {
        $configFile = "TestDrive:\Config.json"

        Set-Content -Path $configFile -Value ( `
            @{ SettingGroup=@{
                    GroupItem1="SettingsGroup:Item1"; 
                    GroupItem2="SettingsGroup:Item2"}; 
                StandaloneSetting="Standalone"} `
                | ConvertTo-Json)

        It "Read Standalone Setting" {
            (Get-Configuration -ConfigFile $configFile).StandaloneSetting | Should Be "Standalone"
        }

        It "Read Setting Group" {
            (Get-Configuration -ConfigFile $configFile).SettingGroup | Should Be "@{GroupItem1=SettingsGroup:Item1; GroupItem2=SettingsGroup:Item2}"
        }

        It "Read Setting Group Child Setting" {
            (Get-Configuration -ConfigFile $configFile).SettingGroup.GroupItem1 | Should Be "SettingsGroup:Item1"
        }
    }
}
