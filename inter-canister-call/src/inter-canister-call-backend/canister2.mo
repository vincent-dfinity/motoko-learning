import Debug "mo:base/Debug";

actor Canister2 {
    var num: Nat = 0;

    public func setValue(value : Nat) : async () {
        num := value;
    };

    public query func getValue() : async Nat {
        Debug.print("Hello from canister 2!");
        return num;
    };
}
