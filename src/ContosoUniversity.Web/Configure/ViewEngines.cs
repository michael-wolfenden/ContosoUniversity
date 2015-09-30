using System.Web.Mvc;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void ViewEngines(ViewEngineCollection views)
        {
            RemoveWebFormsViewEngine(views);
        }

        // PERF: remove unused web forms view engine
        private static void RemoveWebFormsViewEngine(ViewEngineCollection views)
        {
            views.Clear();
            views.Add(new RazorViewEngine());
        }
    }
}