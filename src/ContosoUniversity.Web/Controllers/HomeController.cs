using System.Web.Mvc;
using Serilog;

namespace ContosoUniversity.Web.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger _logger;

        public HomeController(ILogger logger)
        {
            _logger = logger;
        }

        [Route("")]
        public string Index()
        {
            _logger.Information("Index");
            return "Hello World";
        }
    }
}