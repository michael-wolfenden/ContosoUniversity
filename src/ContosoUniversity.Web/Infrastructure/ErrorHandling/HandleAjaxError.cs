using System.Web.Mvc;
using ContosoUniversity.Web.Infrastructure.AspMvc;
using Serilog;

namespace ContosoUniversity.Web.Infrastructure.ErrorHandling
{
    public class HandleAjaxError : HandleErrorAttribute
    {
        public override void OnException(ExceptionContext filterContext)
        {
            if (filterContext.ExceptionHandled) return;

            var request = filterContext.HttpContext.Request;
            if (!request.IsAjaxRequest()) return;

            var exception = filterContext.Exception;
            var includeStackTrace = !filterContext.HttpContext.IsCustomErrorEnabled;
            var ajaxError = AjaxError.FromException(exception, includeStackTrace);

            if (ajaxError.ShouldLog)
            {
                Log.Error(exception, "An unhandled exception was thrown: {ErrorMessage}.", exception.Message);
            }

            filterContext.Result = new JsonNetResult()
            {
                JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                Data = ajaxError
            };

            filterContext.HttpContext.Response.StatusCode = (int) ajaxError.StatusCode;
            filterContext.ExceptionHandled = true;
        }
    }
}