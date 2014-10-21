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


interface ITransientService { }

interface ISingletonService { }

class ServiceWithMultipleCostructors {
   this(ISingletonService singleton) {
      _singletonService = singleton;
   }

   this(ITransientService transient) {
      _transientService = transient;
   }

   private ITransientService _transientService;
   @property ITransientService transientService()  { return _transientService; }

   private ISingletonService _singletonService;
   @property ISingletonService singletonService() { return _singletonService; }
}

class ServiceWithoutPublicConstructor {
   private this() { }
}

class ServiceWithTwoParametersBothDependentOnSameService {
   private ServiceWithDependency _one;
   @property ServiceWithDependency one() { return _one; }
   private AnotherServiceWithDependency _another;
   @property AnotherServiceWithDependency another() { return _another; }

   this(ServiceWithDependency one, AnotherServiceWithDependency another) {
      _one = one;
      _another = another;
   }
}
