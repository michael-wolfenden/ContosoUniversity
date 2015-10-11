using System;
using System.Web;
using System.Web.Mvc;
using Microsoft.Ajax.Utilities;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace ContosoUniversity.Web.Infrastructure.AspMvc
{
    public class JsonNetResult : JsonResult
    {
        private readonly JsonSerializerSettings _serializerSettings;

        public JsonNetResult()
        {
            _serializerSettings = new JsonSerializerSettings()
            {
                DateFormatHandling = DateFormatHandling.IsoDateFormat,
                ContractResolver = new CamelCasePropertyNamesContractResolver()
            };
        }

        public override void ExecuteResult(ControllerContext context)
        {
            if (context == null) throw new ArgumentNullException(nameof(context));

            HttpResponseBase response = context.HttpContext.Response;

            response.ContentType = ContentType;
            if (ContentType.IsNullOrWhiteSpace())
            {
                response.ContentType = "application/json";
            }

            if (ContentEncoding != null)
            {
                response.ContentEncoding = ContentEncoding;
            }

            if (Data == null) return;

            var formatting = Formatting.None;
            if (HttpContext.Current != null && HttpContext.Current.IsDebuggingEnabled)
            {
                formatting = Formatting.Indented;
            }

            JsonTextWriter writer = new JsonTextWriter(response.Output)
            {
                Formatting = formatting
            };

            JsonSerializer
                .Create(_serializerSettings)
                .Serialize(writer, Data);

            writer.Flush();
        }
    }
}