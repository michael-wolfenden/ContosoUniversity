using System.Web.Mvc;
using ContosoUniversity.Web.Infrastructure.AspMvc;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void ViewEngines(ViewEngineCollection views)
        {
            AddFeatureViewViewEngine(views);
        }

        private static void AddFeatureViewViewEngine(ViewEngineCollection views)
        {
            views.Clear();
            views.Add(new FeatureViewLocationRazorViewEngine());
        }
    }
}