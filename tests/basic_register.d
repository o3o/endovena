module tests.basic_register;

import std.stdio;

import unit_threaded;

import tests.utils;
import endovena;

interface IService { }

class SomeService: IService { }

interface IClient {
   @property IService service();
}

class SomeClient : IClient {
   public this(IService service) {
      _service = service;
   }
   private IService _service;
   @property IService service() { return _service; }
}

@UnitTest
void Register_client_and_service_as_types_and_then_resolve() {
   Container container = new Container;

   container.register!(IService, SomeService)();
   container.register!(IClient, SomeClient)();
   auto client = container.get!IClient();
   client.shouldNotBeNull;
   client
      .instanceof!SomeClient
      .shouldBeTrue;

   client.service
      .instanceof!SomeService
      .shouldBeTrue;
}
@UnitTest
void register_client_with_factory_delegate() {
   Container container = new Container;
   container.register!IClient(r => new SomeClient(r.get!IService()));
   container.register!(IService, Singleton)(r => new SomeService());

   auto client = container.get!IClient();
   client.shouldNotBeNull;

   client
      .instanceof!SomeClient
      .shouldBeTrue;

   client.service
      .instanceof!SomeService
      .shouldBeTrue;

   IService s1 = container.get!IService;
   IService s2 = container.get!IService;
   s1.shouldEqual(s2);
}

@UnitTest
void Specify_how_to_reuse_resolved_objects() {
   Container container = new Container();

   /*
    *Transient reuse means no reuse at all.
    *Every time client is resolved/injected a new object will be created.
    */
   container.register!(IClient, SomeClient, Transient)();

   /*
    * You can omit reuse parameter when registering Transient objects.
    *container.register!(IClient, SomeClient, Reuse.Transient)();
    */

   /*
    *Singleton means that service object will be created at first resolve/injection,
    *then the same instance will be returned for all subsequent resolves from this container.
    */
   container.register!(IService, SomeService, Singleton)();

   auto client = container.get!(IClient);
   auto anotherClient = container.get!(IClient);

   assert(client !is anotherClient);
   assert(client.service is anotherClient.service);
}
