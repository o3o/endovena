module tests.template_register;

import std.stdio;
import std.array;
import unit_threaded;

import tests.utils;
import endovena;

interface IQueue(T) {
   void enqueue(T value);
   T dequeue();
}

class Queue(T): IQueue!(T) {
   private T[] data;

   void enqueue(T value) {
      this.data ~= value;
   }

   T dequeue() {
      T x = this.data.front();
      this.data.popFront();
      return x;
   }
}

interface IQueueClient(T) {
   @property IQueue!T service();
}

class QueueClient(T): IQueueClient!T {
   public this(IQueue!T service) {
      _service = service;
   }
   private IQueue!T _service;
   @property IQueue!T service() { return _service; }
}


@UnitTest
void register_as_types() {
   Container container = new Container;

   container.register!(IQueue!int, Queue!int)();
   container.register!(IQueueClient!int, QueueClient!int)();

   auto q = container.get!(IQueue!int)();
   q.instanceof!(Queue!int).shouldBeTrue;

   auto client = container.get!(IQueueClient!int)();
   client.shouldNotBeNull;
   client
      .instanceof!(QueueClient!int)
      .shouldBeTrue;

   client.service
      .instanceof!(Queue!int)
      .shouldBeTrue;
}
/*
template Foo(bool numeric) {
   static if (numeric) {
      alias Type = int;
   } else {
      alias Type = string;
   }
   //enum x = Concat();

   class Concat {
      string con(Type a) {
         return a.stringof;
      }
   }
}

@UnitTest
void register_template() {
   auto c = new Foo!(true).Concat;
   c.con(3).shouldEqual("int");
   //Container container = new Container;
   //container.register!(IQueue!int, Queue!int)();
} 
*/
