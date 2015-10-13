using System.Web.Optimization;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void Bundles(BundleCollection bundles)
        {
            RegisterJsBundles(bundles);
            RegisterCssBundles(bundles);
        }

        private static void RegisterCssBundles(BundleCollection bundles)
        {
            bundles.Add(new StyleBundle("~/bundles/app-css")
                .Include("~/assets/css/bootstrap.css")
            );
        }

        private static void RegisterJsBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/vendor-js")
                .Include("~/assets/js/jquery-2.1.4.js")
            );

            bundles.Add(new ScriptBundle("~/bundles/app-js")
                .IncludeDirectory("~/Features/", "*.js", searchSubdirectories: true)
            );
        }
    }
}