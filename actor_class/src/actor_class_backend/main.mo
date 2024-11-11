import Array "mo:base/Array";
import Buckets "Buckets";
import Cycles "mo:base/ExperimentalCycles";
import IC "mo:base/ExperimentalInternetComputer";
import List "mo:base/List";
import Principal "mo:base/Principal";

actor Map {
  let num = 8; // Number of buckets.

  type Key = Nat;
  type Value = Text;

  type Bucket = Buckets.Bucket;

  let buckets : [var ?Bucket] = Array.init(num, null);
  var principals = List.nil<Principal>();

  public func whoami() : async Principal {
    return Principal.fromActor(Map);
  };

  public func get(key : Key) : async ?Value {
    switch(buckets[key % num]) {
      case null null;
      case (?bucket) await bucket.get(key);
    }
  };

  public func put(key : Key, value : Value) : async () {
    let index = key % num;

    let bucket = switch (buckets[index]) {
      case null {
        // Add Bucket if it's not added.
        // Calls to a class constructor must be provisioned with cycles to pay for the creation of a principal.
        Cycles.add<system>(1_000_000_000_000);
        let bucket = await Buckets.Bucket(num, index);
        buckets[index] := ?bucket;
        bucket;
      };
      case (?bucket) bucket;
    };

    await bucket.put(key, value);

    let principal = Principal.fromActor(bucket);
    principals := List.push(principal, principals);
  };

  public func controlledPrincipals() : async [Principal] {
    return List.toArray(principals);
  };  

  // TODO: Revisit this while working on inter-canister calls.
  // public func addController(canisterId: Principal, controller: Principal) : async () {
  //   let controllers : ?[Principal] = ?[canisterId, Principal.fromActor(Map)];

  //   await IC.update_settings(({ canister_id = canisterId; settings = {
  //     controllers = controllers;
  //   }}))
  // }
};
