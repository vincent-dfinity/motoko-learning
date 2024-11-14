import Bool "mo:base/Bool";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Module "module";
import NestedModule "nested_module";

actor {
  public func testModules() : async () {
    Debug.print(Module.name);

    Debug.print(NestedModule.Person.name);
    Debug.print(Nat.toText(NestedModule.Person.age));
    Debug.print(NestedModule.place);
    
    let adult = NestedModule.checkAge(NestedModule.Person.age);
    Debug.print(Bool.toText(adult));
  };
};
