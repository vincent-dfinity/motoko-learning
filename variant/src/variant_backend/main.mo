import Debug "mo:base/Debug";

actor {
  // Simple Variant.
  type Color = {
    #Red;
    #Green;
    #Blue;
  };

  // Variant with attached type.
  type Person = {
    #Male : Nat;
    #Female : Nat;
  };

  public query func test() : async () {
    let color = #Red;
    Debug.print(debug_show(color));

    let person = #Male 32;
    Debug.print(debug_show(person));
  };
};
