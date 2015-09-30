using System;
using System.Net;
using System.Threading.Tasks;
using System.Web;
using Serilog;

namespace ContosoUniversity.Web.Infrastructure.ErrorHandling
{
    public class ErrorHandlingModule : IHttpModule
    {
        public static void Register()
        {
            HttpApplication.RegisterModule(typeof(ErrorHandlingModule));
        }

        public void Init(HttpApplication application)
        {
            var logger = Log.Logger.ForContext<ErrorHandlingModule>();

            application.LogRequest += (sender, args) =>
            {
                var statusCode = application.Response.StatusCode;
                if (statusCode == (int) HttpStatusCode.NotFound)
                {
                    logger.Error("Page not found: {Url}", application.Request.RawUrl);
                }
            };

            application.Error += (_, eventArgs) =>
                SafelyLogException(logger, application.Server.GetLastError(), "An unhandled exception was thrown: {ErrorMessage}.");

            AppDomain.CurrentDomain.UnhandledException += (_, eventArgs) =>
                SafelyLogException(logger, eventArgs.ExceptionObject as Exception, "An unobserved exception was thrown: {ErrorMessage}.");

            TaskScheduler.UnobservedTaskException += (_, eventArgs) =>
                SafelyLogException(logger, eventArgs.Exception, "An unobserved exception was thrown on a TaskScheduler thread: {ErrorMessage}.");
        }

        private void SafelyLogException(ILogger logger, Exception exception, string template)
        {
            if (exception == null) return;
            logger.Error(exception, template, exception.Message);
        }

        public void Dispose()
        {
            // noop
        }
    }
}