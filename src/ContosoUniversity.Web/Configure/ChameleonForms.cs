using ChameleonForms;
using ChameleonForms.Templates.TwitterBootstrap3;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void ChameleonForms()
        {
            FormTemplate.Default = new TwitterBootstrapFormTemplate();
            HumanizedLabels.Register();
        }
    }
}