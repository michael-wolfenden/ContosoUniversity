using Autofac;
using AutofacSerilogIntegration;

namespace ContosoUniversity.Web.AutofacModules
{
    public class LoggerModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            builder.RegisterLogger();
        }
    }
}