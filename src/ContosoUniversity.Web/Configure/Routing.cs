using System.Web.Mvc;
using System.Web.Routing;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void Routing(RouteCollection routes)
        {
            // Improve SEO by stopping duplicate URL's due to case differences or trailing slashes.
            // See http://googlewebmastercentral.blogspot.co.uk/2010/04/to-slash-or-not-to-slash.html
            routes.AppendTrailingSlash = true;
            routes.LowercaseUrls = true;

            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            routes.IgnoreRoute("assets/{*pathInfo}");

            UseAttributeRouting(routes);
        }

        private static void UseAttributeRouting(RouteCollection routes)
        {
            routes.MapMvcAttributeRoutes();
        }
    }
}