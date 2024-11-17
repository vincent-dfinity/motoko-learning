import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Text "mo:base/Text";

actor {
  // A tuple
  let person = ("Male", 29);

  // A record
  let human = {
    name = "Vincent";
    nation = "China";
  };

  public query func test() : async () {
    // Match a tuple into variables.
    let (gender, age) = person;
    Debug.print(gender);
    Debug.print(Int.toText(age));

    // Match a tuple, but skip the second value in the tuple.
    let (gender1, _) = person;
    Debug.print(gender1);


    // Match a record.
    let { name ; nation } = human;
    Debug.print(name);
    Debug.print(nation);

    // Match only one field.
    let { name = name1 } = human;
    Debug.print(name1);

    // Match an anonymous record which is destructured into its three Text fields.
    let theFullName = fullName( { first = "Jane"; mid = "M"; last = "Doe" });
    Debug.print(theFullName);

    let optionalName = ?"Jane";
    Debug.print(getName(optionalName));
    Debug.print(getName(null));

    // Check the `variant` example for matching a variant.
    // https://github.com/vincent-dfinity/motoko-learning/tree/main/variant
  };

  func fullName({ first : Text; mid : Text; last : Text }) : Text {
    first # " " # mid # " " # last
  };

  func getName(optionalName : ?Text) : Text {
    // let-else pattern matching.
    let ?name = optionalName else return "Empty";
    name;
  }
};
