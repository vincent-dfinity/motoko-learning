actor {
  type Balance = {
    var balance : Nat;
    addAmount : Nat -> Nat;
    reduceAmount : Nat -> Nat;
  };

  let balance : Balance = object {
    private let initialBalance = 100;
    public var balance = initialBalance;
    
    public func addAmount(amount : Nat) : Nat {
      balance += amount;
      balance
    };

    public func reduceAmount(amount : Nat) : Nat {
      assert(amount <= balance);

      balance -= amount;
      balance
    };
  };

  public query func getBalance() : async Nat {
    balance.balance
  };

  public func addBalance(value : Nat) : async Nat {
    balance.addAmount(value)
  };

  public func reduceAmount(value : Nat) : async Nat {
    balance.reduceAmount(value)
  };
};
