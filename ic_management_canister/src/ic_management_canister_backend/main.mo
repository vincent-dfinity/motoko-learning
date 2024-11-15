import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Interface "ic_management_canister";

actor {
  let IC = actor("aaaaa-aa") : Interface.Self;

  stable var canisterPrincipal : ?Principal = null;

  public func create_canister() : async Text {
    let id = switch(canisterPrincipal) {
      case (?id) id;
      case (null) {
        Cycles.add<system>(10 ** 12);

        let newCanister = await IC.create_canister( { settings = null });
        canisterPrincipal := ?newCanister.canister_id;
        newCanister.canister_id
      }
    };

    Principal.toText(id)
  };

  public func canister_status(id : Principal) : async Interface.canister_status_result {
    await IC.canister_status( { canister_id = id })
  };

  public func getCanisterId() : async Text {
    switch(canisterPrincipal) {
      case (?id) Principal.toText(id);
      case (null) return "Empty";
    };
  };
};
