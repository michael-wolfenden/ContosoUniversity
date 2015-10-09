using System.Web.Mvc;
using ContosoUniversity.Web.Infrastructure.ErrorHandling;

// ReSharper disable once CheckNamespace
namespace ContosoUniversity.Web
{
    public static partial class Configure
    {
        public static void GlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleAjaxValidationError(), 2);
            filters.Add(new HandleAjaxError(), 1);
        }
    }
}