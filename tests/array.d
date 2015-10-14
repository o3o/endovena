module tests.array;

import std.stdio;
//import core.exception;
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
   container.register!(IDependency, Dependency)("Foo3");
   container.register!(IService, ServiceWithArrayDependencies)();

   auto service = container.get!(IService)();
   service.shouldNotBeNull;

   ServiceWithArrayDependencies sA = cast(ServiceWithArrayDependencies)(service);
   sA.foos.length.shouldEqual(3);
   sA.foos[0].instanceof!Dependency.shouldBeTrue;
}

@UnitTest
void i_can_resolve_array_of_named() {
   Container container = new Container;
   container.register!(IService, ServiceA, Singleton)("A");
   container.register!(IService, ServiceA, Singleton)("B");
   container.register!(IService, ServiceA, Singleton)("C");
   auto services = container.get!(IService[])();
   services.length.shouldEqual(3);
}

@UnitTest
void singleton_is_scoped_by_name() {
   Container container = new Container;
   container.register!(IService, ServiceA, Singleton)("A");
   container.register!(IService, ServiceA, Singleton)("B");
   container.register!(IService, ServiceA, Singleton)("C");
   IService a1 = container.get!IService("A");
   IService a2 = container.get!IService("A");
   IService b1 = container.get!IService("B");
   IService b2 = container.get!IService("B");

   shouldBeTrue(a1 is a2);
   shouldBeTrue(b1 is b2);
   shouldBeFalse(b1 is a1);
   shouldBeFalse(b2 is a2);
   shouldBeFalse(b2 is a1);
}

@UnitTest
void i_can_resolve_transient_array_of_different_named_service() {
   Container container = new Container;
   container.register!(IService, ServiceA)("A");
   container.register!(IService, ServiceB)("B");

   auto services = container.get!(IService[])();
   services.length.shouldEqual(2);

   container.get!IService("A").instanceof!ServiceA.shouldBeTrue;
   container.get!IService("B").instanceof!ServiceB.shouldBeTrue;

   auto s1 = container.get!IService("A");
   auto s2 = container.get!IService("A");
   shouldBeFalse(s1 == s2);
}

@UnitTest
void i_can_resolve_singleton_array_of_different_named_service() {
   Container container = new Container;
   container.register!(IService, ServiceA, Singleton)("A");
   container.register!(IService, ServiceB, Singleton)("B");
   auto services = container.get!(IService[])();
   services.length.shouldEqual(2);
   container.get!IService("A").instanceof!ServiceA.shouldBeTrue;
   container.get!IService("B").instanceof!ServiceB.shouldBeTrue;
   auto s1 = container.get!IService("A");
   auto s2 = container.get!IService("A");
   shouldBeTrue(s1 is s2);
   shouldBeTrue(s1 == s2);
}

@UnitTest
void i_can_resolve_array_of_different_named_service() {
   Container container = new Container;
   container.register!(IService)(c => new ServiceA, "A");
   container.register!(IService)(c => new ServiceB, "B1");
   container.register!(IService)(c => new ServiceB, "B2");
   auto services = container.get!(IService[])();
   services.length.shouldEqual(3);
   container.get!IService("A").instanceof!ServiceA.shouldBeTrue;
   container.get!IService("B1").instanceof!ServiceB.shouldBeTrue;
   container.get!IService("B2").instanceof!ServiceB.shouldBeTrue;
   auto b1 = container.get!IService("B1");
   auto b2 = container.get!IService("B2");
   shouldBeFalse(b1 is b2);
   shouldBeFalse(b1 == b2);
}

@UnitTest
void resolving_array_of_not_registered_services_should_throw() {
Container container = new Container;
   container.get!(IService[]).shouldThrow!ResolveException;
}
