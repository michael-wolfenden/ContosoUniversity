using System.Web.Optimization;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void Bundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/vendor")
                .Include("~/Assets/vendor/reqwest.js")
            );

            bundles.Add(new ScriptBundle("~/bundles/app")
                .IncludeDirectory("~/Features/", "*.js", searchSubdirectories: true)
            );
        }
    }
}