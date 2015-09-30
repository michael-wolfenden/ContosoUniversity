using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using Autofac.Integration.Mvc;
using Serilog;

namespace ContosoUniversity.Web
{
    public class MvcApplication : HttpApplication
    {
        private void Application_Start(object sender, EventArgs e)
        {
            try
            {
                Log.Logger = Configure.Logging();
                Log.Information("Application starting");

                IoC.Startup();

                Configure.AspMvc(IoC.Container, RouteTable.Routes, ViewEngines.Engines);

                AppDomain.CurrentDomain.UnhandledException += OnCurrentDomainUnhandledException;
                TaskScheduler.UnobservedTaskException += OnUnobservedTaskException;
            }
            catch
            {
                // make sure we try to run Application_Start again next request
                // see: http://blog.richardszalay.com/2007/03/08/dealing-with-exceptions-thrown-in-application_start/
                HttpRuntime.UnloadAppDomain();
                throw;
            }
        }

        protected void Application_End(object sender, EventArgs e)
        {
            Log.Information("Application ending");
            IoC.Shutdown();
        }

        private static void OnCurrentDomainUnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            Log.Error("An unobserved exception was thrown.", e.ExceptionObject as Exception);
        }

        private static void OnUnobservedTaskException(object sender, UnobservedTaskExceptionEventArgs e)
        {
            Log.Error("An unobserved exception was thrown on a TaskScheduler thread.", e.Exception);
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            var exception = Server.GetLastError();
            Log.Error(exception, "An unhandled exception was thrown: {Message}.", exception.Message);
        }
    }
}
