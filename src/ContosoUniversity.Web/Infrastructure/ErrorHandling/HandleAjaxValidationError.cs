using System.Linq;
using System.Net;
using System.Web.Mvc;
using FluentValidation;

namespace ContosoUniversity.Web.Infrastructure.ErrorHandling
{
    public class HandleAjaxValidationError : HandleErrorAttribute
    {
        public HandleAjaxValidationError()
        {
            ExceptionType = typeof (ValidationException);
        }

        public override void OnException(ExceptionContext filterContext)
        {
            if (filterContext.ExceptionHandled) return;

            var exception = filterContext.Exception;
            if (!ExceptionType.IsInstanceOfType(exception)) return;

            var request = filterContext.HttpContext.Request;
            if (!request.IsAjaxRequest()) return;

            var validationException = exception as ValidationException;

            filterContext.Result = new JsonResult
            {
                JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                Data = new
                {
                    message = "The request is invalid",
                    validationErrors = validationException
                                .Errors
                                .GroupBy(failure => failure.PropertyName)
                                .ToDictionary(failures => failures.Key, failures => failures.Select(failure => failure.ErrorMessage))
                }
            };

            filterContext.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
            filterContext.ExceptionHandled = true;
        }
    }
}