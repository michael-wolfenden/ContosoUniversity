using Autofac;
using ContosoUniversity.Web.Infrastructure.Mediatr;
using ContosoUniversity.Web.Infrastructure.Mediatr.Decorators;

namespace ContosoUniversity.Web.AutofacModules
{
    public class MediatrModule : Module
    {
        protected override void Load(ContainerBuilder builder)
        {
            // decorators are executed in reverse order of registration
            // validation -> your handler

            new AutofacMediatorBuilder(builder)
                    .WithRequestHandlerAssemblies(ThisAssembly)
                    .WithNotificationHandlerAssemblies(ThisAssembly)
                    .UseValidationDecorator()
                    .Build();
        }
    }
}