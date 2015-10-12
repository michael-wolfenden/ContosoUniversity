using System.Web.Helpers;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void AntiForgeryTokens()
        {
            // Rename the Anti-Forgery cookie from "__RequestVerificationToken" to "f".This adds a little security
            // through obscurity and also saves sending a few characters over the wire. Sadly there is no way to change 
            // the form input name which is hard coded in the @Html.AntiForgeryToken helper and the 
            // ValidationAntiforgeryTokenAttribute to  __RequestVerificationToken.
            // <input name="__RequestVerificationToken" type="hidden" value="..." />
            AntiForgeryConfig.CookieName = "f";
            AntiForgeryConfig.RequireSsl = true;
        }
    }
}