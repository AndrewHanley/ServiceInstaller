# Service Installer

The service installer project was created to build a process for deploying Windows Services created in .NET to remote computers using PowerShell.

## Setup

| Tool                                                                        | Version       |
|-----------------------------------------------------------------------------|---------------|
| [Visual Studio Code](https://code.visualstudio.com/)                        | 1.12.2        |
| [Visual Studio Community 2017](https://www.visualstudio.com/vs/community/)  | 15.2          |
| [git](https://git-scm.com/)                                                 | 2.13.0        |
| [PowerShell](https://msdn.microsoft.com/en-us/powershell/mt173057.aspx)     | 5.1.15063.296 |


## Visual Studio Code

Editing of the scripts in the project was performed with [Visual Studio Code](https://code.visualstudio.com/)

* If VS Code is used for maintenance and OS is older than Windows 10, [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) will be required
* The process for debugging PowerShell with VS Code can be found [here](https://github.com/PowerShell/PowerShell/blob/master/docs/learning-powershell/using-vscode.md#debugging-with-visual-studio-code)

## Visual Studio Community 2017

Creation of Windows Service was performed with [Visual Studio Community 2017](https://www.visualstudio.com/vs/community/)

The Windows Service is just a shell and has absolutely no functionality. The intent was just to create a Windows Service with .NET that makes use of **Installer** classes so that use
of InstallUtil could be automated for service installation.

## Unit Testing

Unit testing for the the project was performed using [Pester](https://github.com/pester/Pester), a framework for **running unit tests to execute and validate PowerShell commands from within PowerShell**.

## Return vs. By Ref Parameters

In PowerShell when a statement like $result = GET-FUNC is written **ALL** output generated within the function is collected into an array and returned not just the variable specfied by the **return** statement [<sup>1</sup>](#references). For example the following script;

```dos
    function Get-Result()
    {
        Write-Output "Hello World"
        return "Result"
    }

    $result = Get-Result
```

The **$result** variable will contain;

* Hello World
* Result

To address the return statement issue, functions within the project scripts, that are expected to return data now do so through the use of **By Reference** Parameters [<sup>2</sup>](#references). Implementation of the above with reference parameters would be;

```dos
    function Get-Result([ref]$retVal)
    {
        Write-Output "Hello World"
        $retVal.Value = "Result"
    }

    Get-Result -retVal ([ref]$result)
```

The **$result** variable will now contain;

* Result

----

## References

1: [About Return](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_return)

2: [By Reference Parameters](http://stackoverflow.com/questions/5175377/return-object-from-powershell-using-a-parameter-by-reference-parameter/5183337#5183337)