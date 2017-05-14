using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace TestService
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        private static void Main()
        {
            if (!Environment.UserInteractive)
            {
                RunAsService();
            }
            else
            {
                RunAsConsole();
            }
        }

        private static void RunAsService()
        {
            ServiceBase[] servicesToRun = { new TestingService() };
            ServiceBase.Run(servicesToRun);
        }

        private static void RunAsConsole()
        {
            var currentDomain = AppDomain.CurrentDomain;
            currentDomain.UnhandledException += CurrentDomain_UnhandledException;

            var service = new TestingService();

            var keyPressed = ConsoleKey.A;

            while (keyPressed != ConsoleKey.Q)
            {
                keyPressed = Console.ReadKey().Key;

                switch (keyPressed)
                {
                    case ConsoleKey.Q:
                        service.Stop();
                        break;
                }
            }
        }

        private static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            var ex = (Exception)e.ExceptionObject;

            Console.WriteLine(ex.Message);
            Console.WriteLine(ex.StackTrace);
            Console.ReadKey();
        }
    }
}
