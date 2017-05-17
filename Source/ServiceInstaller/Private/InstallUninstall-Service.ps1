function Install-Service 
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias("Service", "Name", "SN")]
        [string]$ServiceName,

        [Parameter(Mandatory=$true, Position=1)]
        [Alias("Path")]
        [string]$ServicePath,

        [Parameter(ParameterSetName="Credentials", Mandatory=$true, Position=2)]
        [Alias("Server", "Serv")]
        [string]$TargetServer,

        [Parameter(ParameterSetName="Credentials", Mandatory=$true, Position=3)]
        [Alias("Cred", "C")]
        [pscredential]$Credentials,

        [Parameter(ParameterSetName="Session", Mandatory=$true, Position=2)]
        [Alias("Sess", "S")]
        [System.Management.Automation.Runspaces.PSSession]$Session,

        [Parameter(ParameterSetName="Credentials", Position=4)]
        [Parameter(ParameterSetName="Session", Position=3)]
        [switch]$x64
    )

    if ($x64)
    {
        $scriptBlock =  { C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /LogFile /install `"$($args[0])`" }
    }
    else
    {
        $scriptBlock =  { C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /LogFile /install `"$($args[0])`" }
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        "Credentials" {
            $service = Get-Service -ComputerName $TargetServer -Name $ServiceName -ErrorAction SilentlyContinue

            if (!($service))
            {
                $output = Invoke-Command `
                            -ComputerName $TargetServer `
                            -Credential $Credentials `
                            -ScriptBlock $scriptBlock `
                            -ArgumentList $ServicePath
            }
        }

        "Session" {
            $service = Invoke-Command `
                            -Session $Session `
                            -ScriptBlock { Get-Service -Name $($args[0]) -ErrorAction SilentlyContinue } `
                            -ArgumentList $ServiceName

            if (!($service))
            {
                $output = Invoke-Command `
                            -Session $Session `
                            -ScriptBlock $scriptBlock `
                            -ArgumentList $ServicePath
            }
        }
    }

    if (!($output -contains "The Commit phase completed successfully.") -and ![string]::IsNullOrEmpty($output))
    {
        Throw "Installation of $ServiceName Failed `n `n $output"
    }
}

function Uninstall-Service 
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [Alias("Service", "Name", "SN")]
        [string]$ServiceName,

        [Parameter(Mandatory=$true, Position=1)]
        [Alias("Path")]
        [string]$ServicePath,

        [Parameter(ParameterSetName="Credentials", Mandatory=$true, Position=2)]
        [Alias("Server", "Serv")]
        [string]$TargetServer,

        [Parameter(ParameterSetName="Credentials", Mandatory=$true, Position=3)]
        [Alias("Cred", "C")]
        [pscredential]$Credentials,

        [Parameter(ParameterSetName="Session", Mandatory=$true, Position=2)]
        [Alias("Sess", "S")]
        [System.Management.Automation.Runspaces.PSSession]$Session,

        [Parameter(ParameterSetName="Credentials", Position=4)]
        [Parameter(ParameterSetName="Session", Position=3)]
        [switch]$x64
    )

    if ($x64)
    {
        $scriptBlock =  { C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /LogFile /uninstall `"$($args[0])`" }
    }
    else
    {
        $scriptBlock =  { C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /LogFile /uninstall `"$($args[0])`" }
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        "Credentials" {
            $service = Get-Service -ComputerName $TargetServer -Name $ServiceName -ErrorAction SilentlyContinue

            if ($service)
            {
                $output = Invoke-Command `
                            -ComputerName $TargetServer `
                            -Credential $Credentials `
                            -ScriptBlock $scriptBlock `
                            -ArgumentList $ServicePath
            }
        }

        "Session" {
            Enter-PSSession $Session

            $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

            if ($service)
            {
                $output = Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $ServicePath
            }

            Exit-PSSession
        }
    }


    if (!($output -contains "Service $ServiceName was successfully removed from the system.") -and ![string]::IsNullOrEmpty($output))
    {
        Throw "Uninstallation of $ServiceName Failed `n `n $output"
    }
}
