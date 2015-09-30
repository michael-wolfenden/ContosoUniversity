using System.Web.Mvc;
using System.Web.Routing;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void Routing(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            UseAttributeRouting(routes);
        }

        private static void UseAttributeRouting(RouteCollection routes)
        {
            routes.MapMvcAttributeRoutes();
        }
    }
}