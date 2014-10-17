module tests.container;

import std.stdio;
import unit_threaded;
import core.exception;

import endovena;
import tests.utils;
import tests.cut;

@UnitTest
void get_service_should_return_registered_implementation() {
   Container container = new Container;
   container.register!(IService, Service);

   auto service = container.get!IService;
   service.instanceof!Service.shouldBeTrue;
}

@UnitTest
void given_named_and_default_registerations_Get_without_name_returns_default() {
   Container container = new Container;
   container.register!(IService, Service);
   container.register!(IService, AnotherService)("another");

   auto service = container.get!IService();
   service.instanceof!Service.shouldBeTrue;
}

@UnitTest
void given_named_and_default_registerations_Get_with_name_should_return_correspondingly_named_service() {
   Container container = new Container;
   container.register!(IService, Service);
   container.register!(IService, AnotherService)("another");
   auto service = container.get!IService("another");
   service.instanceof!AnotherService.shouldBeTrue;
}

@UnitTest
void given_two_named_registerations_Get_without_name_should_throw() {
   Container container = new Container;
   container.register!(IService, Service)("some");
   container.register!(IService, Service)("another");
   (container.get!IService()).shouldThrow!RangeError;
}

@UnitTest
void resolving_singleton_twice_should_return_same_instances() {
   Container container = new Container;
   container.register!(IService, Service, Singleton);
   auto one = container.get!IService;
   auto another = container.get!IService;
   assert(one is another);
   another.shouldEqual(one);
}

@UnitTest
void Resolving_non_registered_service_should_throw() {
   Container container = new Container;
   (container.get!IService()).shouldThrow!RangeError;
}

interface ITransientService { }

interface ISingletonService { }

class ServiceWithMultipleCostructors {
   this(ISingletonService singleton) {
      _singletonService = singleton;
   }

   this(ITransientService transient) {
      _transientService = transient;
   }

   private ITransientService _transientService;
   @property ITransientService transientService()  { return _transientService; }

   private ISingletonService _singletonService;
   @property ISingletonService singletonService() { return _singletonService; }
}

@UnitTest
void Given_no_constructor_selector_specified_in_registration_Resolving_implementation_with_multiple_constructors_should_throw() {
   Container container = new Container;
   //container.register!(ITransientService, TransientService);
   container.register!(ServiceWithMultipleCostructors);
   (container.get!ServiceWithMultipleCostructors()).shouldThrow!RangeError;
}

@UnitTest
void given_registered_service_Injecting_it_as_dependency_should_work() {
   Container container = new Container;
   container.register!(IDependency, Dependency);
   container.register!(ServiceWithDependency);
   auto service = container.get!ServiceWithDependency;
   service.shouldNotBeNull;
}

@UnitTest
void resolving_service_with_NON_registered_dependency_should_throw() {
   Container container = new Container;
   container.register!(ServiceWithDependency);
   (container.get!ServiceWithDependency()).shouldThrow!RangeError;
}

//void Resolving_service_with_recursive_dependency_should_throw()
@UnitTest
void given_two_resolved_service_instances_Injected_singleton_dependency_should_be_the_same_in_both() {
   Container container = new Container;
   container.register!(IDependency, Dependency, Singleton);
   container.register!(ServiceWithDependency);
   auto one = container.get!ServiceWithDependency;
   auto another = container.get!ServiceWithDependency;
   one.dependency.shouldEqual(another.dependency);
}
