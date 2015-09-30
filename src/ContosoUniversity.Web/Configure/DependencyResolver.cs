using Autofac;
using Autofac.Integration.Mvc;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void DependencyResolver(IContainer container)
        {
            UseAutofacDependencyResolver(container);
        }

        private static void UseAutofacDependencyResolver(IContainer container)
        {
            System.Web.Mvc.DependencyResolver.SetResolver(new AutofacDependencyResolver(container));
        }
    }
}