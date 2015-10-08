using System.Web.Mvc;

namespace ContosoUniversity.Web.Features.Home
{
    [RoutePrefix("Home")]
    public class HomeController : Controller
    {
        [Route("~/")]
        [Route("")]
        public ActionResult Index()
        {
            return View();
        }
    }
}