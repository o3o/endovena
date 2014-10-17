module tests.cut;
interface IDependency { }
class Dependency : IDependency { }
interface IService { }
class Service: IService { }
class ServiceA: IService { }
class ServiceB: IService { }
class AnotherService : IService { }
class ServiceWithDependency : IService {
   private IDependency _dependency;
   @property IDependency dependency() { return _dependency; }
   this(IDependency dependency) {
      _dependency = dependency;
   }
}

class AnotherServiceWithDependency : IService {
   private IDependency _dependency;
   @property IDependency dependency() { return _dependency; }
   this(IDependency dependency) {
      _dependency = dependency;
   }
}

class ServiceWithArrayDependencies: IService {
   private IDependency[] _foos;
   @property IDependency[] foos() { return _foos; }

   public this(IDependency[] foos) {
      _foos = foos;
   }
}
