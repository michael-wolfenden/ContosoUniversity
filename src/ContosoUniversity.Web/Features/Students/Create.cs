using System;
using System.Threading.Tasks;
using FluentValidation;
using MediatR;

namespace ContosoUniversity.Web.Features.Students
{
    public class Create
    {
        public class Command : IAsyncRequest
        {
            public string LastName { get; set; }
            public string FirstMidName { get; set; }
            public DateTime? EnrollmentDate { get; set; }
        }

        public class Validator : AbstractValidator<Command>
        {
            public Validator()
            {
                RuleFor(m => m.LastName).NotNull().Length(1, 50);
                RuleFor(m => m.FirstMidName).NotNull().Length(1, 50);
                RuleFor(m => m.EnrollmentDate).NotNull();
            }
        }

        public class Handler : AsyncRequestHandler<Command>
        {
            protected override Task HandleCore(Command message)
            {
                return Task.CompletedTask;
            }
        }
    }
}