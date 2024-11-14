import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Option "mo:base/Option";
import Result "mo:base/Result";

actor {
  private func print(optionInt : ?Int) : () {
    // Match option value.
    switch optionInt {
      case null {
        Debug.print("Value is null.")
      };
      case (?value) {
        Debug.print("Value is " # Int.toText(value));
      }
    };
  };

  public query func testOption() : async () {
    var optionInt1 : ?Int = null;
    print(optionInt1);

    optionInt1 := ?42;
    print(optionInt1);

    let optionInt2 = Option.make(42);
    assert(optionInt2 == optionInt1);
  };

  type CompareResult = Result.Result<Int, Text>;

  public query func greaterThan100 (value : Int) : async CompareResult {
    if (value > 100) {
      return #ok(value);
    } else {
      return #err("Value " # Int.toText(value) # " is not greater than 100");
    }
  };
};
