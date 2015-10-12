using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using Autofac;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure 
    {
        public static void AspMvc(IContainer container, RouteCollection routes, ViewEngineCollection views, BundleCollection bundles, GlobalFilterCollection filters)
        {
            Configure.Routing(routes);
            Configure.ViewEngines(views);
            Configure.DependencyResolver(container);
            Configure.Bundles(bundles);
            Configure.GlobalFilters(filters);
            Configure.AntiForgeryTokens();
            Configure.ChameleonForms();

            // remove X-AspNetMvc-Version header
            MvcHandler.DisableMvcResponseHeader = true;
        }
    }
}