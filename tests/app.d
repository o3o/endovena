import unit_threaded.runner;
import std.stdio;

import tests.container;
import tests.usage;
import tests.func;
import tests.array;
import tests.basic_register;
import tests.template_register;

import endovena;

int main(string[] args) {
   return runTests!(
         endovena
         , tests.container
         , tests.usage
         , tests.func
         , tests.array
         , tests.basic_register
         , tests.template_register
         //, tests.named
         ) (args);
}
