# Service Installer

The service installer project was created to build a process for deploying Windows Services created in .NET to remote computers using PowerShell.

## Setup

Service Installer uses PowerShell script files to deploy the Windows Service files. The project was built on a Windows 10 system
running PowerShell version 5.1.15063.0.

## Visual Studio Code

Editing of the scripts in the project was performed with [Visual Studio Code](https://code.visualstudio.com/)

* If VS Code is used for maintenance and OS is older than Windows 10, [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) will be required
* The process for debugging PowerShell with VS Code can be found [here](https://github.com/PowerShell/PowerShell/blob/master/docs/learning-powershell/using-vscode.md#debugging-with-visual-studio-code)

## Return vs. By Ref Parameters

In PowerShell when a statement like $result = GET-FUNC is written **ALL** output generated within the function is collected into an array and returned not just the variable specfied by the **return** statement[<sup>1</sup>](#about_return). For example the following script;

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

To address the return statement issue functions that are expected to return data now do so through the use of **By Reference** Parameters. See Search-Environment for implementation details.

----

## Footnotes

<a name="about_Return">1</a>: [About Return](https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_return)