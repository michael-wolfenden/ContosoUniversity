using System;
using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
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

                Configure.AspMvc(IoC.Container, RouteTable.Routes, ViewEngines.Engines, BundleTable.Bundles, GlobalFilters.Filters);
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
    }
}
