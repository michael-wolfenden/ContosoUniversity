using ConfigInjector.QuickAndDirty;
using ContosoUniversity.Web.ConfigurationSettings;
using Serilog;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static ILogger Logging()
        {
            var assemblyName = Constants.WebAssembly.GetName().Name;
            var assemblyVersion = Constants.WebAssembly.GetName().Version;

            var minimumLogLevel = DefaultSettingsReader.Get<MinimumLogLevelSetting>();
            var environment = DefaultSettingsReader.Get<EnvironmentSetting>();
            var seqServerUri = DefaultSettingsReader.Get<SeqServerUriSetting>();

            var loggerConfig = new LoggerConfiguration()
                                .MinimumLevel.Is(minimumLogLevel)
                                .Enrich.FromLogContext()
                                .Enrich.WithMachineName()
                                .Enrich.WithThreadId()
                                .Enrich.WithProperty("ApplicationName", assemblyName)
                                .Enrich.WithProperty("ApplicationVersion", assemblyVersion)
                                .Enrich.WithProperty("Environment", environment)
                                .WriteTo.Seq(seqServerUri.ToString())
                                .WriteTo.Trace();

            return loggerConfig.CreateLogger();
        }
    }
}