using ConfigInjector;
using Serilog.Events;

namespace ContosoUniversity.Web.ConfigurationSettings
{
    public class MinimumLogLevelSetting : ConfigurationSetting<LogEventLevel>
    {
    }
}