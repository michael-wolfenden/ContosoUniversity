using System.Threading.Tasks;
using Autofac;
using FluentValidation;
using MediatR;

namespace ContosoUniversity.Web.Infrastructure.Mediatr.Decorators
{
    public class ValidationRequestHandler<TRequest, TResponse> : IRequestHandler<TRequest, TResponse> where TRequest : IRequest<TResponse>
    {
        private readonly IRequestHandler<TRequest, TResponse> _innerHandler;
        private readonly ILifetimeScope _lifetimeScope;

        public ValidationRequestHandler(IRequestHandler<TRequest, TResponse> innerHandler, ILifetimeScope lifetimeScope)
        {
            _innerHandler = innerHandler;
            _lifetimeScope = lifetimeScope;
        }

        public TResponse Handle(TRequest message)
        {
            IValidator<TRequest> validator = _lifetimeScope.ResolveOptional<IValidator<TRequest>>();

            if (validator != null)
            {
                validator.ValidateAndThrow(message);
            }

            var response = _innerHandler.Handle(message);

            return response;
        }
    }

    public class AsyncValidationRequestHandler<TRequest, TResponse> : IAsyncRequestHandler<TRequest, TResponse> where TRequest : IAsyncRequest<TResponse>
    {
        private readonly IAsyncRequestHandler<TRequest, TResponse> _innerHandler;
        private readonly ILifetimeScope _lifetimeScope;

        public AsyncValidationRequestHandler(IAsyncRequestHandler<TRequest, TResponse> innerHandler, ILifetimeScope lifetimeScope)
        {
            _innerHandler = innerHandler;
            _lifetimeScope = lifetimeScope;
        }

        public async Task<TResponse> Handle(TRequest message)
        {
            IValidator<TRequest> validator = _lifetimeScope.ResolveOptional<IValidator<TRequest>>();

            if (validator != null)
            {
                await validator.ValidateAsync(message);
            }

            var response = await _innerHandler.Handle(message);

            return response;
        }
    }

    public static class ValidationRequestHandlerExtensions
    {
        public static AutofacMediatorBuilder UseValidationDecorator(this AutofacMediatorBuilder builder)
        {
            builder.WithRequestDecorator("ValidationRequestHandler", typeof(ValidationRequestHandler<,>));
            builder.WithRequestDecorator("AsyncValidationRequestHandler", typeof(AsyncValidationRequestHandler<,>));

            return builder;
        }
    }
}