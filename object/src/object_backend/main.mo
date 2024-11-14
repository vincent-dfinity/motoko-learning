import Result "mo:base/Result";

actor {
  type BalanceResult = Result.Result<Nat, Text>;

  type Balance = {
    var balance : Nat;
    addAmount : Nat -> BalanceResult;
    reduceAmount : Nat -> BalanceResult;
  };

  let balance : Balance = object {
    private let initialBalance = 100;
    public var balance = initialBalance;
    
    public func addAmount(amount : Nat) : BalanceResult {
      balance += amount;
      #ok(balance)
    };

    public func reduceAmount(amount : Nat) : BalanceResult {
      if (amount > balance) {
        return #err("Balance is insufficient.")
      };

      balance -= amount;
      #ok(balance)
    };
  };

  public query func getBalance() : async Nat {
    balance.balance
  };

  public func addBalance(value : Nat) : async BalanceResult {
    balance.addAmount(value)
  };

  public func reduceAmount(value : Nat) : async BalanceResult {
    balance.reduceAmount(value)
  };
};
