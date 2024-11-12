import Canister2 "canister:canister2";

actor Main {
  public func getValue() : async Nat {
    return await Canister2.getValue();
  };

  public func setValue(value : Nat) : async () {
    await Canister2.setValue(value)
  }
};
