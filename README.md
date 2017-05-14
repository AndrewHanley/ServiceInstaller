# Service Installer

The service installer project was created to build a process for deploying Windows Services created in .NET to remote computers using PowerShell.

## Setup

Service Installer uses PowerShell script files to deploy the Windows Service files. The project was built on a Windows 10 system
running PowerShell version 5.1.15063.0.

## Visual Studio Code

Editing of the scripts in the project was performed with [Visual Studio Code](https://code.visualstudio.com/)

* If VS Code is used for maintenance and OS is older than Windows 10, [Windows Management Framework 5.0](https://www.microsoft.com/en-us/download/details.aspx?id=50395) will be required
* The process for debugging PowerShell with VS Code can be found [here](https://github.com/PowerShell/PowerShell/blob/master/docs/learning-powershell/using-vscode.md#debugging-with-visual-studio-code)

## Resources

### [Deploying a Windows Service remotely with PowerShell](http://www.ben-morris.com/deploying-a-windows-service-remotely-with-powershell/)

### [Installing a Windows Wervice Using PowerShell](http://blog.aggregatedintelligence.com/2011/12/installing-windows-service-using.html)

### [Install a Windows Service Remotely with PowerShell](http://www.geoffhudik.com/tech/2012/3/22/install-a-windows-service-remotely-with-powershell.html)