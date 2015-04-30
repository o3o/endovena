module tests.usage;

import std.stdio;
import core.exception;

import unit_threaded;

import endovena;
import tests.cut;

class User {
   string name;
   this(string name) {
      this.name = name;
   }
}

interface IGreeter {
   string greet();
}

class Greeter: IGreeter {
   string greet() { return "Hello"; }
}

class GreeterWithName: IGreeter {
   private User user;
   this(User x) {
      user = x;
   }
   string greet() { return "Hello " ~ user.name; }
}

class GreeterWithMsg: IGreeter {
   private string _msg;
   this(string msg) {
      _msg = msg;
   }
   string greet() { return _msg ~ "!"; }
}

@UnitTest
void register_with_function() {
   Container container = new Container;

   container.registerFunc!(IGreeter, Singleton)(function () => new Greeter());
   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

@UnitTest
void register_with_function_lambda() {
   Container container = new Container;
   container.registerFunc!(IGreeter, Singleton)(() => new Greeter());

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

@UnitTest
void register_with_delegate() {
   Container container = new Container;
   container.register!(IGreeter, Singleton)(delegate() { return new Greeter(); } );
   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

@UnitTest
void register_with_delegate_short() {
   Container container = new Container;
   container.register!(IGreeter, Singleton)( { return new Greeter(); } );
   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

@UnitTest
void register_with_delegate_lambda() {
   Container container = new Container;
   container.register!(IGreeter, Singleton)(() => new Greeter());

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

@UnitTest
void register_with_FunctionProvider() {
   Container container = new Container;
   auto p = new FunctionProvider( () => new Greeter());
   container.register!(IGreeter, Singleton)(p);

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

@UnitTest
void register_instance() {
   Container container = new Container;
   container.register!(GreeterWithMsg, Singleton)(new GreeterWithMsg("a"));

   auto service = container.get!GreeterWithMsg();
   service.shouldNotBeNull;
   service.greet.shouldEqual("a!");
}

@UnitTest
void register_with_InstanceProvider() {
   Container container = new Container;
   auto p = new InstanceProvider(new Greeter());
   container.register!(IGreeter, Singleton)(p);

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

@UnitTest
void given_service_with_ctor_Register_with_InstanceProvider_should_work() {
   Container container = new Container;
   auto p = new InstanceProvider(new GreeterWithMsg("a"));
   container.register!(IGreeter, Singleton)(p);

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("a!");
}

@UnitTest
void given_service_with_ctor_Register_instance_should_work() {
   Container container = new Container;
   auto g = new GreeterWithMsg("a");
   auto p = new InstanceProvider(g);
   container.register!(IGreeter, Singleton)(p);

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("a!");
}

@UnitTest
void given_service_registred_by_instance_Get_interface_should_throw() {
   Container container = new Container;
   container.register!Greeter;
   auto service = container.get!Greeter();
   service.shouldNotBeNull;
   container.get!IGreeter.shouldThrow!ResolveException;
}

@UnitTest
void given_services_registred_by_instance_and_interface_Get_should_works() {
   Container container = new Container; 
   container.register!Greeter;
   container.register!(IGreeter,Greeter);

   auto service = container.get!Greeter();
   service.shouldNotBeNull;
   auto iservice = container.get!IGreeter();
   iservice.shouldNotBeNull;
   assert(iservice !is service);
}
