import Nat "mo:base/Nat";
import Bool "mo:base/Bool";

actor TrapCommit{
  var num = 0;

  var pinged = false;

  func ping() : async () {
    pinged := true;
  };

  public func getNum() : async Nat {
    return num;
  };

  public func getPinged() : async Bool {
    return pinged;
  };

  public func atomic() : async () {
    num := 1;
    ignore ping();

    ignore 0/0; // trap.
  };

  public func nonAtomic() : async () {
    num := 1;

    let f = ping();
    await f; // "await" is a commit point, so the state before it cannot be rolled back.

    ignore 0/0; // trap.
  }
};
