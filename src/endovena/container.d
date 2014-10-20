//          Copyright Orfeo Da Via 2014.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module endovena.container;
import std.conv : to;
import std.functional : toDelegate;
import std.stdio : writefln;
import std.traits;

import endovena.provider;
import endovena.reuse;

interface Module {
   void configure(Container dejector);
}

class Container {
   private Binding[string] bindings;
   private Reuse[string] scopes;

   this(Module[] modules) {
      this.bindReuse!Transient;
      this.bindReuse!Singleton;

      foreach(module_; modules) {
         module_.configure(this);
      }
   }

   this() {
      this([]);
   }

   void bindReuse(Class)() {
      immutable key = getKey!Class;
      if(key in this.scopes) {
         throw new Exception("Scope already bound");
      }
      this.scopes[key] = new Class();
   }

   void register(C, R: Reuse = Transient)() {
      this.register!(C, C, R)("");
   }

   void register(C, R: Reuse = Transient)(C instance) {
      this.register!(C, R)(new InstanceProvider(instance));
   }

   void register(I, C, R: Reuse = Transient)() {
      this.register!(I, R)(new ClassProvider!C(this), "");
   }

   void register(I, R: Reuse = Transient)(Provider provider) {
      this.register!(I, R)(provider, "");
   }

   void register(I, R: Reuse = Transient)(Object delegate() provide) {
      this.register!(I, R)(new FunctionProvider(provide));
   }

   void register(I, R: Reuse = Transient)(Object delegate(Container) factory) {
      this.register!(I, R)(new FactoryProvider(this, factory));
   }

   void register(I, R: Reuse = Transient)(Object function() provide) {
      this.register!(I, R)(toDelegate(provide));
   }

   void register(C, R: Reuse = Transient)(string name) {
      this.register!(C, C, R)(name);
   }

   void register(I, C, R: Reuse = Transient)(string name) {
      this.register!(I, R)(new ClassProvider!C(this), name);
   }

   void register(I, R: Reuse = Transient)(Provider provider, string name) {
      immutable key = getKey!I(name);
      if (key in this.bindings) {
         throw new Exception("Interface already bound");
      }
      this.bindings[key] = createBinding!(I, R)(provider, name);
   }
   

   private Binding createBinding(I, S)(Provider provider, string name) {
      auto resolutionReuse = this.scopes[fullyQualifiedName!S];
      return Binding(fullyQualifiedName!I
            , name
            , provider
            , resolutionReuse);
   }

   T get(T)() {
      static if(is(T t == I[], I)) {
         I[] array;
         string requestedFQN = fullyQualifiedName!I;
         foreach (binding; bindings) {
            if (binding.fqn == requestedFQN) {
               array ~= get!I;
            }
         }
         return array;
      } else {
         return get!T("");
      }
   }

   I get(I)(string name) {
      immutable key = getKey!I(name);
      auto binding = this.bindings[key];
      return cast(I) binding.resolutionReuse.get(key, binding.provider);
   }

   I delegate() getDelegate(I)() {
      return delegate() { return this.get!I; };
   }
}

private struct Binding {
   string fqn; // fullyQualifiedName
   string name; // name in named instance
   Provider provider;
   Reuse resolutionReuse;
}

private string getKey(T)() {
   return getKey!T("");
}

private string getKey(T)(string name) {
   if (name.length == 0) {
      return fullyQualifiedName!T;
   } else {
      return fullyQualifiedName!T  ~ "." ~ name;
   }
}
