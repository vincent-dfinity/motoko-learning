import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";

actor {
  type User = {
    name : Text;
    age : Nat;
    timeRegistration : Time.Time;
  };

  type CreateUser = {
    name : Text;
    age : Nat;
  };

  let userMap = HashMap.HashMap<Principal, User>(0, Principal.equal, Principal.hash);

  // Call from comand line to have a principal 
  // > dfx canister call hash_map_backend createUser '(record { name = "Vincent"; age = 30})'
  public shared ({ caller }) func createUser(createUser : CreateUser) : async Result.Result<(), Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("Cannot register an anonymous user.");
    };

    switch(userMap.get(caller)) {
      case(null) {
        let user = {
          name = createUser.name;
          age = createUser.age;
          timeRegistration = Time.now();
        };
        userMap.put(caller, user);
        return #ok();
      };
      case (?_) {
        return #err("User " # Principal.toText(caller) # " has been registered.");
      };
    };
  };

  // > dfx canister call hash_map_backend getUser '(principal "--Your principal--")'
  public func getUser(principal : Principal) : async Result.Result<User, Text> {
    switch(userMap.get(principal)) {
      case(null) {
        return #err("User " # Principal.toText(principal) # " does not exist.");
      };
      case (?user) {
        return #ok(user);
      };
    };
  };
};
