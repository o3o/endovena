//          Copyright Orfeo Da Via 2014.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module endovena.container;
import std.conv : to;
import std.functional : toDelegate;
import std.stdio;
import std.traits;

import std.algorithm;
import std.array;
import std.range;

import endovena.provider;
import endovena.reuse;

interface Module {
   void configure(Container dejector);
}

class Container {
   private Binding[] bindings;
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
      immutable key = fullyQualifiedName!Class;
      if(key in this.scopes) {
         throw new Exception("Scope already bound");
      }
      this.scopes[key] = new Class();
   }

   void register(C, R: Reuse = Transient)() {
      this.register!(C, C, R)("");
   }

   void register(C, R: Reuse = Transient)(C instance) {
      this.register!(C, R)(new InstanceProvider(instance), "");
   }

   void register(I, C, R: Reuse = Transient)() {
      this.register!(I, R)(new ClassProvider!C(this), "");
   }

   void register(I, R: Reuse = Transient)(Provider provider) {
      this.register!(I, R)(provider, "");
   }

   void register(I, R: Reuse = Transient)(Object delegate() provide) {
      this.register!(I, R)(new FunctionProvider(provide), "");
   }

   void register(I, R: Reuse = Transient)(Object delegate(Container) factory) {
      this.register!(I, R)(new FactoryProvider(this, factory), "");
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
      if (exists!I(name)) {
         throw new RegistrationException("Interface already bound", fullyQualifiedName!I);
      }
      this.bindings ~= createBinding!(I, R)(provider, name);
   }

   void register(I, R: Reuse = Transient)(Object delegate() provide, string name) {
      this.register!(I, R)(new FunctionProvider(provide), name);
   }

   void register(I, R: Reuse = Transient)(Object delegate(Container) factory,
         string name) {
      this.register!(I, R)(new FactoryProvider(this, factory), name);
   }

   private bool exists(I)(string name) {
      return !filterExactly!I(name).empty;
   }

   private Binding createBinding(I, R)(Provider provider, string name) {
      auto reuse = this.scopes[fullyQualifiedName!R];
      return Binding(fullyQualifiedName!I
            , name
            , provider
            , reuse);
   }

   I get(I)(string name) {
      Binding[] binding = filterExactly!I(name);
      if (binding.empty) {
         throw new ResolveException("Type not registered."
               , fullyQualifiedName!I
               , name);
      }
      return resolve!I(binding[0]);
   }


   T get(T)() {
      static if(is(T t == I[], I)) {
         I[] array;
         Binding[] filtered = filterByInterface!I;
         if (filtered.empty) {
            throw new ResolveException("Type not registered.", fullyQualifiedName!T);
         }

         foreach (Binding binding; filtered) {
            array ~= resolve!I(binding);
         }
         return array;
      } else {
         Binding[] binding = filterExactly!T("");
         if (binding.empty) {
            throw new ResolveException("Type not registered.", fullyQualifiedName!T);
         }
         return resolve!T(binding[0]);
      }
   }

   private Binding[] filterByInterface(I)() {
      string requestedFQN = fullyQualifiedName!I;
      return bindings.filter!(a => a.fqn == requestedFQN).array;
   }

   private Binding[] filterExactly(I)(string name) {
      string requestedFQN = fullyQualifiedName!I;
      return bindings.filter!(a => a.fqn == requestedFQN && a.name == name).array;
   }

   private I resolve(I)(Binding binding) {
      string key = fullyQualifiedName!I;
      if (binding.name.length > 0) {
         key ~= binding.name;
      }
      return cast(I) binding.reuse.get(key, binding.provider);
   }

   I delegate() getDelegate(I)() {
      return delegate() { return this.get!I; };
   }
}

import std.string;
class ResolveException: Exception {
   this(string message, string key, string name) {
      super(format("Exception while resolving type %s named %s: %s", key, name, message));
   }
   this(string message, string key) {
      super(format("Exception while resolving type %s: %s", key, message));
   }
}

class RegistrationException : Exception {
   this(string message, string key) {
      super(format("Exception while registering type %s: %s", key, message));
   }
}

package struct Binding {
   string fqn; // fullyQualifiedName
   string name; // name in named instance
   Provider provider;
   Reuse reuse;
}
