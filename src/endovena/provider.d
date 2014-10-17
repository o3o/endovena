//          Copyright Orfeo Da Viá 2014.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module endovena.provider;

import std.string : chomp;
import std.traits;

import endovena.container;

interface Provider {
   Object get();
}

class ClassProvider(T): Provider {
   private Container container;
   this(Container container) {
      this.container = container;
   }

   Object get() {
      return create!T(container);
   }
}

class FunctionProvider: Provider {
   private Object delegate() provide;

   this(Object delegate() provide) {
      this.provide = provide;
   }

   Object get() {
      return this.provide();
   }
}

class FactoryProvider: Provider {
   private Container container;
   private Object delegate(Container) provide;
   this(Container container, Object delegate(Container) provide) {
      this.container = container;
      this.provide = provide;
   }

   Object get() {
      return this.provide(container);
   }
}

class InstanceProvider: Provider {
   private Object instance;

   this(Object instance) {
      this.instance = instance;
   }

   Object get() {
      return this.instance;
   }
}

private T create(T)(Container container) {
   auto instance = cast(T) _d_newclass(T.classinfo);
   mixin(generateCtor!T);
   return instance;
}

unittest {
   class Foo { } 
   class Bar { 
      this(Foo f) { }
   } 
   class Fun { 
      this(Foo[] ff) { }
   } 
   class A{ }
   class B{ }
   class Piss { 
      this(A a, B b) { }
   } 

   import std.stdio;
   import unit_threaded;
   Bar b = new Bar(new Foo);

   writeln("=== foo ===");
   string foo  = generateCtor!Foo;
   writeln(foo);

   writeln("=== bar ==");
   writeln(generateCtor!Bar);

   //writeln("=== Foo[] ==");
   //writeln(generateCtor!(Foo[]));

   writeln("=== Fun ==");
   writeln(generateCtor!(Fun));

   writeln("=== Piss ==");
   writeln(generateCtor!(Piss));
}

extern (C) Object _d_newclass(const TypeInfo_Class ci);

private string generateCtor(T)() {
   enum ARGUMENT_SEPARATOR = ", ";
   string code; 
   static if (hasMember!(T, "__ctor")) {
      foreach (type; ParameterTypeTuple!(T.__ctor)) {
         static if(is(type t == I[], I)) {
            code ~= "import " ~ moduleName!I ~ ";";
         } else {
            code ~= "import " ~ moduleName!type ~ ";";
         }
      }

      code ~= "instance.__ctor(";
      foreach (type; ParameterTypeTuple!(T.__ctor)) {
         code ~= "container.get!(" ~ fullyQualifiedName!type ~ ")" ~
            ARGUMENT_SEPARATOR;
      }
      code = chomp(code, ARGUMENT_SEPARATOR) ~ ");";
   }
   return code;
}
