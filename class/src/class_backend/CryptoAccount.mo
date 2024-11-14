import Result "mo:base/Result";

module {
  public type PayResult = Result.Result<Nat, Text>;
  
  public class CryptoAccount(amount : Nat) {
    public var balance = amount;

    public func pay(amount : Nat) : PayResult {
      if (amount > balance) {
        return #err("Balance is insufficient.");
      };

      balance -= amount;
      #ok(balance)
    };
  };
}
