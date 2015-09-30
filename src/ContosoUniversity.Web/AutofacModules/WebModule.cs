using Autofac;
using Autofac.Integration.Mvc;

namespace ContosoUniversity.Web.AutofacModules
{
    public class WebModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            builder.RegisterControllers(ThisAssembly);
        }
    }
}