//          Copyright Orfeo Da Viá 2014.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module endovena.reuse;

import endovena.provider;

interface Reuse {
   Object get(string key, Provider provider);
}

class Transient: Reuse {
   Object get(string key, Provider provider) {
      return provider.get;
   }
}

class Singleton: Reuse {
   private Object[string] instances;

   Object get(string key, Provider provider) {
      if(key !in this.instances) {
         this.instances[key] = provider.get;
      }
      return this.instances[key];
   }
}
