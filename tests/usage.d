module tests.usage;

import std.stdio;
import core.exception;

import unit_threaded;

import endovena;

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
   // doesn't work
   //container.register!(IGreeter, Singleton)(() => new Greeter());

   container.register!(IGreeter, Singleton)(function () => new Greeter());
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
void register_with_FunctionProvider() {
   Container container = new Container;
   auto p = new FunctionProvider( () => new Greeter());
   container.register!(IGreeter, Singleton)(p);

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
}

import std.functional : toDelegate;
@UnitTest
void register_with_toDelegate() {
   Container container = new Container;
   container.register!(IGreeter, Singleton)(toDelegate( () => new Greeter()  ));

   auto service = container.get!IGreeter();
   service.shouldNotBeNull;
   service.greet.shouldEqual("Hello");
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
