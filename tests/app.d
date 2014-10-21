import unit_threaded.runner;
import std.stdio;

import tests.container;
import tests.usage;
import tests.func;
import tests.array;
import tests.basic_register;

import endovena;

int main(string[] args) {
   return runTests!(
         endovena
         , tests.container
         , tests.usage
         , tests.func
         , tests.array
         , tests.array
         //, tests.named
         ) (args);
}
