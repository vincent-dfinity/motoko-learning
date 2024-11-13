import Canister2 "canister:canister2";

actor Main {
  // This cannot be a query function as query functions don't have message send capability.
  public func getValue() : async Nat {
    return await Canister2.getValue();
  };

  public func setValue(value : Nat) : async () {
    await Canister2.setValue(value)
  }
};
