using System.Net;
using System.Web.Mvc;
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

            Log.Error(exception, "An ajax error occured [{HttpMethod} {Url}]", request.HttpMethod, request.Url);

            // do not leak sensitive information in higher environments
            var errorMessage = filterContext.HttpContext.IsCustomErrorEnabled
                ? "An exception has occured"
                : exception.Message;

            filterContext.Result = new JsonResult
            {
                JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                Data = new
                {
                    message = errorMessage
                }
            };

            filterContext.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
            filterContext.ExceptionHandled = true;
        }
    }
}