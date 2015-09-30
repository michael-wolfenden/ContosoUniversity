using Autofac;
using Serilog;

namespace ContosoUniversity.Web
{
    public class IoC
    {
        public static IContainer Container { get; private set; }

        public static void Startup()
        {
            Log.Information("IoC Container Startup");

            var builder = new ContainerBuilder();
            builder.RegisterAssemblyModules(Constants.WebAssembly);

            Container = builder.Build();
        }

        public static void Shutdown()
        {
            Log.Information("IoC Container Shutdown");

            Container?.Dispose();
        }
    }
}