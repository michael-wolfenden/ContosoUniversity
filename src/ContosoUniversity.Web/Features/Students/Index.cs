using System.Threading.Tasks;
using MediatR;

namespace ContosoUniversity.Web.Features.Students
{
    public class Index
    {
        public class Query : IAsyncRequest<Result>
        {
        }

        public class Result
        {
            public string Message { get; set; }
        }

        public class Handler : IAsyncRequestHandler<Query, Result>
        {
            public Task<Result> Handle(Query message)
            {
                return Task.FromResult(new Result()
                {
                    Message = "Hello World"
                });
            }
        }
    }
}