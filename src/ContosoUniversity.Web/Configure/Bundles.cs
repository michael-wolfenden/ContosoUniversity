using System.Web.Optimization;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void Bundles(BundleCollection bundles)
        {
            System.Web.Optimization.BundleTable.EnableOptimizations = true;


            bundles.Add(new ScriptBundle("~/bundles/vendor")
                .Include("~/Assets/vendor/jquery-2.1.4.js")
            );

            bundles.Add(new ScriptBundle("~/bundles/app")
                .IncludeDirectory("~/Features/", "*.js", searchSubdirectories: true)
            );
        }
    }
}