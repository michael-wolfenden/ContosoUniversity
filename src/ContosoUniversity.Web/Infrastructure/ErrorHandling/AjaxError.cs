using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using FluentValidation;
using Newtonsoft.Json;

namespace ContosoUniversity.Web.Infrastructure.ErrorHandling
{
    public class AjaxError
    {
        public HttpStatusCode StatusCode { get; }
        public string Message { get; }

        [JsonIgnore()]
        public bool ShouldLog { get; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string Details { get; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public Dictionary<string, IEnumerable<string>> Errors { get; }

        private AjaxError(HttpStatusCode statusCode, string details, Logging logging, Dictionary<string, IEnumerable<string>> errors)
        {
            StatusCode = statusCode;
            Message = HttpWorkerRequest.GetStatusDescription((int)statusCode);
            Details = details;
            ShouldLog = logging == Logging.Log;
            Errors = errors;
        }

        public static AjaxError FromException(Exception exception, bool includeStackTrace)
        {
            var validationException = exception as ValidationException;
            if (validationException != null) return CreateFromValidationException(validationException, includeStackTrace);
            
            return CreateFromException(exception, includeStackTrace);
        }

        private static AjaxError CreateFromException(Exception exception, bool includeStackTrace)
        {
            var details = includeStackTrace ? exception.ToString() : null;
            return new AjaxError(HttpStatusCode.InternalServerError, details, Logging.Log, null);
        }

        private static AjaxError CreateFromValidationException(ValidationException exception, bool includeStackTrace)
        {
            var details = includeStackTrace ? exception.ToString() : null;

            var errors = exception
               .Errors
               .GroupBy(failure => failure.PropertyName)
               .ToDictionary(failures => failures.Key, failures => failures.Select(failure => failure.ErrorMessage));

            return new AjaxError(HttpStatusCode.BadRequest, details, Logging.DontLog, errors);
        }

        private enum Logging
        {
            DontLog,
            Log
        }
    }
}