module tests.container;

import std.stdio;
import unit_threaded;
import core.exception;

import endovena;
import tests.utils;
import tests.cut;

//10
@UnitTest
void get_service_should_return_registered_implementation() {
   Container container = new Container;
   container.register!(IService, Service);

   auto service = container.get!IService;
   service.instanceof!Service.shouldBeTrue;
}

//21
@UnitTest
void given_named_and_default_registerations_Get_without_name_returns_default() {
   Container container = new Container;
   container.register!(IService, Service);
   container.register!(IService, AnotherService)("another");

   auto service = container.get!IService();
   service.instanceof!Service.shouldBeTrue;
}

//31
@UnitTest
void given_named_and_default_registerations_Get_with_name_should_return_correspondingly_named_service() {
   Container container = new Container;
   container.register!(IService, Service);
   container.register!(IService, AnotherService)("another");
   auto service = container.get!IService("another");
   service.instanceof!AnotherService.shouldBeTrue;
}

//45
@UnitTest
void given_two_named_registerations_Get_without_name_should_throw() {
   Container container = new Container;
   container.register!(IService, Service)("some");
   container.register!(IService, Service)("another");
   (container.get!IService()).shouldThrow!ResolveException;
}

//56
@UnitTest
void resolving_singleton_twice_should_return_same_instances() {
   Container container = new Container;
   container.register!(IService, Service, Singleton);
   auto one = container.get!IService;
   auto another = container.get!IService;
   shouldBeTrue(one is another);
   shouldBeTrue(one == another);
}

//68
@UnitTest
void get_non_registered_service_should_throw() {
   Container container = new Container;
   (container.get!IService()).shouldThrow!ResolveException;
}

//77  void Registering_with_interface_for_service_implementation_should_throw()

// 86
@UnitTest
void Given_no_constructor_selector_specified_in_registration_Get_implementation_with_multiple_constructors_should_throw() {
   Container container = new Container;
   container.register!(ServiceWithMultipleCostructors);
   container.get!ServiceWithMultipleCostructors().shouldThrow!ResolveException;
}

//96
@UnitTest
void given_registered_service_Injecting_it_as_dependency_should_work() {
   Container container = new Container;
   container.register!(IDependency, Dependency);
   container.register!(ServiceWithDependency);
   auto service = container.get!ServiceWithDependency;
   service.shouldNotBeNull;
}

//108
@UnitTest
void resolving_service_with_NON_registered_dependency_should_throw() {
   Container container = new Container;
   container.register!(ServiceWithDependency);
   (container.get!ServiceWithDependency()).shouldThrow!ResolveException;
}

//118 void Resolving_service_with_recursive_dependency_should_throw()

//129
@UnitTest
void given_two_resolved_service_instances_Injected_singleton_dependency_should_be_the_same_in_both() {
   Container container = new Container;
   container.register!(IDependency, Dependency, Singleton);
   container.register!(ServiceWithDependency);
   auto one = container.get!ServiceWithDependency;
   auto another = container.get!ServiceWithDependency;
   shouldBeTrue(one.dependency is another.dependency);
}

//155:
void when_resolving_service_with_two_dependencies_dependent_on_singleton_Then_same_singleton_instance_should_be_used() {
   Container container = new Container;
   container.register!(ServiceWithTwoParametersBothDependentOnSameService);
   container.register!(ServiceWithDependency);
   container.register!(AnotherServiceWithDependency);
   container.register!(IDependency, Dependency, Singleton);

   auto service = container.get!(ServiceWithTwoParametersBothDependentOnSameService);
   shouldBeTrue(service.one.dependency is service.another.dependency);
}

//215
@UnitTest
void registering_second_default_implementation_should_throw() {
   Container container = new Container;
   container.register!(IService, Service);
   container.register!(IService, AnotherService)
      .shouldThrow!RegistrationException;
}

//225
@UnitTest
void registering_service_with_duplicate_name_should_throw() {
   Container container = new Container;
   container.register!(IService, Service)("blah");
   container.register!(IService, Service)("blah")
      .shouldThrow!RegistrationException;
}

// 236 not applicab

// Not compilable
//@UnitTest
//void resolving_service_without_public_constructor_should_throw() {
//Container container = new Container;
//container.register!(ServiceWithoutPublicConstructor).shouldThrow!RegistrationException;;
//}

@UnitTest
void given_only_named_registrations_Get_without_name_should_throw() {
   Container container = new Container;
   container.register!(IService, Service)("one");
   container.register!(IService, AnotherService)("another");

   container.get!IService().shouldThrow!ResolveException;
}
