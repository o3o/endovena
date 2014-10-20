module tests.array;

import std.stdio;
import core.exception;
import unit_threaded;

import endovena;
import tests.cut;
import tests.utils;

@UnitTest
void resolving_array_with_default_and_one_named_service_will_return_both_services() {
   Container container = new Container;
   container.register!(IService, Service)();
   container.register!(IService, AnotherService)("another");
   auto services = container.get!(IService[])();
   services.length.shouldEqual(2);
}

@UnitTest
void i_can_resolve_array_of_singletons() {
   Container container = new Container;
   container.register!(IService, ServiceA, Singleton)();
   auto services = container.get!(IService[])();
   services.length.shouldEqual(1);
}

@UnitTest
void I_can_resolve_mixed_array_of_singletons_and_no_scoped() {
   Container container = new Container;
   container.register!(IService, Service, Singleton)();
   container.register!(IService, AnotherService)("another");
   auto services = container.get!(IService[])();
   services.length.shouldEqual(2);
}

@UnitTest
void I_can_inject_array_as_dependency() {
   Container container = new Container;
   container.register!(IDependency, Dependency)();
   container.register!(IDependency, Dependency)("Foo2");
   container.register!(IService, ServiceWithArrayDependencies)();

   auto service = container.get!(IService)();
   service.shouldNotBeNull;
}

//@UnitTest
void given_only_one_named_registration_Get_should_resolve_the_default_service() {
   Container container = new Container;
   container.register!(IDependency, Dependency)("Foo2");
   auto dependency = container.get!(IDependency)();
   dependency.shouldNotBeNull;
   dependency.instanceof!(IService).shouldBeTrue;
}
