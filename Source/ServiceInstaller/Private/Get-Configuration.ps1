<#
    .SYNOPSIS
    Retrieves configuration settings from supplied JSON file and returns settings

    .PARAMETER ConfigFile
    Path and file name to JSON file containing configuration. Defaults to ./Config.json
#>
function Get-Configuration 
{
    [CmdletBinding()]
    param 
    (
        [Alias("file", "config", "f", "c")]
        [string]$ConfigFile = "./Config.json"
    )

    if (!(Test-Path $ConfigFile))
    {
        Throw [System.IO.FileNotFoundException] "Configuration File $ConfigFile Not Found"
    }

    return Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json
}
