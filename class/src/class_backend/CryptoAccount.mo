import Result "mo:base/Result";

module {
  public type AccountResult = Result.Result<Nat, Text>;

  public class CryptoAccount(amount : Nat) {
    var balance = amount;

    public func get() : Nat {
      balance
    };

    public func pay(amount : Nat) : AccountResult {
      if (amount > balance) {
        return #err("Balance is insufficient.");
      };

      balance -= amount;
      #ok(balance)
    };

    public func deposit(amount : Nat) : AccountResult {
      balance += amount;
      #ok(balance);
    }
  };
}
