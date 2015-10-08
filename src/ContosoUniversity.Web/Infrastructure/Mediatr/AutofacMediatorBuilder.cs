using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Autofac;
using Autofac.Core;
using Autofac.Features.Variance;
using MediatR;

namespace ContosoUniversity.Web.Infrastructure.Mediatr
{
    public class AutofacMediatorBuilder
    {
        private readonly ContainerBuilder _builder;
        private const string SyncHandlerKey = "handler";
        private const string AsyncHandlerKey = "async-handler";

        private string _currentSyncHandlerKey = SyncHandlerKey;
        private string _currentAsyncHandlerKey = AsyncHandlerKey;

        private bool _isBuilt;

        public AutofacMediatorBuilder(ContainerBuilder builder)
        {
            _builder = builder;
        }

        public AutofacMediatorBuilder WithRequestHandlerAssemblies(params Assembly[] assemblies)
        {
            if (_isBuilt) throw new Exception("Cannot call WithRequestHandlerAssemblies after Build() has been called");

            foreach (var assembly in assemblies)
            {
                RegisterRequestHandlersFromAssembly(assembly);
                RegisterAsyncRequestHandlersFromAssembly(assembly);
            }

            return this;
        }

        public AutofacMediatorBuilder WithNotificationHandlerAssemblies(params Assembly[] assemblies)
        {
            if (_isBuilt) throw new Exception("Cannot call WithNotificationHandlerAssemblies after Build() has been called");

            foreach (var assembly in assemblies)
            {
                RegisterNotificationHandlersFromAssembly(assembly);
                RegisterAsyncNotificationHandlersFromAssembly(assembly);
            }

            return this;
        }

        public AutofacMediatorBuilder WithRequestDecorator(string name, Type decoratorType)
        {
            if (_isBuilt) throw new Exception("Cannot call WithRequestDecorator after Build() has been called");

            var interfaces = decoratorType.GetInterfaces();

            if (interfaces.Any(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IAsyncRequestHandler<,>)))
            {
                RegisterAsyncRequestDecorator(name, decoratorType);
            }
            else if (interfaces.Any(i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IRequestHandler<,>)))
            {
                RegisterRequestDecorator(name, decoratorType);
            }
            else
            {
                throw new ArgumentException("Decorator type must implement IRequestHandler<TRequest,TResponse> or IAsyncRequestHandler<TRequest, TResponse>", "decoratorType");
            }

            return this;
        }

        private void RegisterRequestDecorator(string name, Type decoratorType)
        {
            _builder
                .RegisterGenericDecorator(decoratorType, typeof(IRequestHandler<,>), _currentSyncHandlerKey)
                .Named(name, typeof(IRequestHandler<,>));

            _currentSyncHandlerKey = name;
        }

        private void RegisterAsyncRequestDecorator(string name, Type decoratorType)
        {
            _builder
                .RegisterGenericDecorator(decoratorType, typeof(IAsyncRequestHandler<,>), _currentAsyncHandlerKey)
                .Named(name, typeof(IAsyncRequestHandler<,>));

            _currentAsyncHandlerKey = name;
        }

        private void RegisterRequestHandlersFromAssembly(Assembly assembly)
        {
            RegisterAssemblyTypesAsClosedTypeOf(assembly, typeof(IRequestHandler<,>), SyncHandlerKey);
        }

        private void RegisterAsyncRequestHandlersFromAssembly(Assembly assembly)
        {
            RegisterAssemblyTypesAsClosedTypeOf(assembly, typeof(IAsyncRequestHandler<,>), AsyncHandlerKey);
        }

        private void RegisterNotificationHandlersFromAssembly(Assembly assembly)
        {
            RegisterAssemblyTypesAsClosedTypeOf(assembly, typeof(INotificationHandler<>));
        }

        private void RegisterAsyncNotificationHandlersFromAssembly(Assembly assembly)
        {
            RegisterAssemblyTypesAsClosedTypeOf(assembly, typeof (IAsyncNotificationHandler<>));
        }

        private void RegisterAssemblyTypesAsClosedTypeOf(Assembly assembly, Type openGenericInterfaceType)
        {
            _builder
               .RegisterAssemblyTypes(assembly)
               .As(type => type.GetInterfaces()
                               .Where(i => i.IsClosedTypeOf(openGenericInterfaceType))
                               .ToArray()
               );
        }

        private void RegisterAssemblyTypesAsClosedTypeOf(Assembly assembly, Type openGenericInterfaceType, string keyedAs)
        {
            _builder
                .RegisterAssemblyTypes(assembly)
                .As(type => type.GetInterfaces()
                            .Where(i => i.IsClosedTypeOf(openGenericInterfaceType))
                            .Select(i => new KeyedService(keyedAs, i))
                );
        }

        public void Build()
        {
            if (_isBuilt) throw new Exception("Build() can only be called once");

            _builder
                .RegisterSource(new ContravariantRegistrationSource());

            _builder
                .RegisterAssemblyTypes(typeof(IMediator).Assembly)
                .AsImplementedInterfaces();

            _builder.Register<SingleInstanceFactory>(ctx =>
            {
                var c = ctx.Resolve<IComponentContext>();
                return t => c.Resolve(t);
            });

            _builder.Register<MultiInstanceFactory>(ctx =>
            {
                var c = ctx.Resolve<IComponentContext>();
                return t => (IEnumerable<object>)c.Resolve(typeof(IEnumerable<>).MakeGenericType(t));
            });

            _builder.RegisterGenericDecorator(
                typeof(WrapperRequestHandler<,>), 
                typeof(IRequestHandler<,>), 
                _currentSyncHandlerKey
            );

            _builder.RegisterGenericDecorator(
                typeof(AsyncWrapperRequestHandler<,>), 
                typeof(IAsyncRequestHandler<,>),
                _currentAsyncHandlerKey
            );

            _isBuilt = true;
        }

        private class WrapperRequestHandler<TRequest, TResponse> : IRequestHandler<TRequest, TResponse> where TRequest : IRequest<TResponse>
        {
            private readonly IRequestHandler<TRequest, TResponse> _innerHandler;

            public WrapperRequestHandler(IRequestHandler<TRequest, TResponse> innerHandler)
            {
                _innerHandler = innerHandler;
            }

            public TResponse Handle(TRequest message)
            {
                return _innerHandler.Handle(message);
            }
        }

        private class AsyncWrapperRequestHandler<TRequest, TResponse> : IAsyncRequestHandler<TRequest, TResponse> where TRequest : IAsyncRequest<TResponse>
        {
            private readonly IAsyncRequestHandler<TRequest, TResponse> _innerHandler;

            public AsyncWrapperRequestHandler(IAsyncRequestHandler<TRequest, TResponse> innerHandler)
            {
                _innerHandler = innerHandler;
            }

            public async Task<TResponse> Handle(TRequest message)
            {
                return await _innerHandler.Handle(message);
            }
        }
    }
}