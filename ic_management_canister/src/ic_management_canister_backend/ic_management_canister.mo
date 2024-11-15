import Principal "mo:base/Principal";

// This is just a subset of IC management API.
// Check the full list https://internetcomputer.org/docs/current/references/ic-interface-spec#ic-candid.
module {
  public type canister_id = Principal;

  public type canister_settings = {
    freezing_threshold : ?Nat;
    controllers : ?[Principal];
    memory_allocation : ?Nat;
    compute_allocation : ?Nat;
  };

  public type definite_canister_settings = {
    freezing_threshold : Nat;
    controllers : [Principal];
    memory_allocation : Nat;
    compute_allocation : Nat;
  };

  public type canister_status_result = {
    status : { #stopped; #stopping; #running };
    memory_size : Nat;
    cycles : Nat;
    settings : definite_canister_settings;
    idle_cycles_burned_per_day : Nat;
    module_hash : ?[Nat8];
  };

  public type wasm_module = [Nat8];

  public type Self = actor {
    canister_status : shared { canister_id : canister_id } -> async canister_status_result;

    create_canister : shared { settings : ?canister_settings } -> async {
      canister_id : canister_id;
    };

    delete_canister : shared { canister_id : canister_id } -> async ();

    deposit_cycles : shared { canister_id : canister_id } -> async ();

    install_code : shared {
      arg : [Nat8];
      wasm_module : wasm_module;
      mode : { #reinstall; #upgrade; #install };
      canister_id : canister_id;
    } -> async ();

    start_canister : shared { canister_id : canister_id } -> async ();

    stop_canister : shared { canister_id : canister_id } -> async ();

    uninstall_code : shared { canister_id : canister_id } -> async ();

    update_settings : shared {
      canister_id : canister_id;
      settings: canister_settings;
    } -> async ();
  };
};
