import unit_threaded.runner;
import std.stdio;

import tests.container;
import tests.usage;
import tests.func;
import tests.array;

import endovena;

int main(string[] args) {
    return runTests!(tests.container
          , tests.usage
          , tests.func
          , endovena
          , tests.array
          ) (args);
}
