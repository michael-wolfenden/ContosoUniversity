using System;
using System.Threading.Tasks;
using System.Web.Mvc;
using MediatR;

namespace ContosoUniversity.Web.Features.Students
{
    [RoutePrefix("Students")]
    public class StudentsController : Controller
    {
        private readonly IMediator _mediator;

        public StudentsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [Route("")]
        public async Task<ActionResult> Index(Index.Query query)
        {
            var response = await _mediator.SendAsync(query);
            return View(response);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [Route("Create")]
        public async Task<ActionResult> Create(Create.Command command)
        {
            await _mediator.SendAsync(command);
            return View();
        }

        [HttpGet]
        [Route("Create")]
        public ActionResult Create()
        {
            return View(new Create.Command());
        }

    }
}