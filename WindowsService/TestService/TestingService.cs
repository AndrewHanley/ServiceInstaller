using System;
using System.Diagnostics;
using System.ServiceProcess;

namespace TestService
{
    public class TestingService : ServiceBase
    {
        private EventLog log;

        public TestingService()
        {
            //if (!EventLog.SourceExists("TestingService"))
            //{
            //    EventLog.CreateEventSource("TestingService", "ServiceLog");
            //}

            //log = new EventLog
            //{
            //    Source = "TestingService",
            //    Log = "ServiceLog"
            //};
        }

        protected override void OnStart(string[] args)
        {
            Console.WriteLine("Service Starting");
            //log.WriteEntry("Service Starting");
        }

        protected override void OnStop()
        {
            Console.WriteLine("Service Stopping");
            //log.WriteEntry("Service Stopping");
        }
    }
}