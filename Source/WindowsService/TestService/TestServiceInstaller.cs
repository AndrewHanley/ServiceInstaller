using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace TestService
{
    [RunInstaller(true)]
    public class TestServiceInstaller : Installer
    {
        public TestServiceInstaller()
        {
            ProcessInstaller = new ServiceProcessInstaller
            {
                Account = ServiceAccount.LocalService
            };

            InterfaceServicesInstaller = new ServiceInstaller
            {
                StartType = ServiceStartMode.Automatic,
                ServiceName = "TestingService",
                DisplayName = "Test Service",
                Description = "This is a test service for the ServiceInstaller Project"
            };

            Installers.AddRange(new Installer[]
            {
                ProcessInstaller,
                InterfaceServicesInstaller
            });
        }

        private ServiceInstaller InterfaceServicesInstaller { get; }
        private ServiceProcessInstaller ProcessInstaller { get; }
    }
}