using System.Web.Mvc;
using System.Web.Routing;
using Autofac;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure 
    {
        public static void AspMvc(IContainer container, RouteCollection routes, ViewEngineCollection views)
        {
            Configure.Routing(routes);
            Configure.ViewEngines(views);
            Configure.DependencyResolver(container);
        }
    }
}