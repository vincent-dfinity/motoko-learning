import Counter "Counter";
import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

actor {
  stable var counter : ?Counter.Counter = null;

  public shared(msg) func greet() : async Text {
    return "Hello, " # Principal.toText(msg.caller) # "!";
  };

  public func read() : async Nat {
    let c = switch (counter) {
      case null {
        await initCounter();
      };
      case (?c) c;
    };

    await c.read()
  };

  public func inc() : async () {
    let c = switch (counter) {
      case null {
        await initCounter();
      };
      case (?c) c;
    };

    await c.inc()
  };

  public func reset() : async Nat {
    let c = switch (counter) {
      case null {
        await initCounter();
      };
      case (?c) c;
    };

    await c.reset()
  };

  func initCounter() : async Counter.Counter{
    Cycles.add<system>(1_000_000_000_000);
    let c = await Counter.Counter(1);
    counter := ?c;
    c
  }
};
