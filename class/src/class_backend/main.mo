import CryptoAccount "CryptoAccount";

actor {
  let account = CryptoAccount.CryptoAccount(100);

  public query func getBalance() : async Nat {
    account.get()
  };

  public func pay(amount : Nat) : async CryptoAccount.AccountResult {
    account.pay(amount)
  };

  public func deposit(amount : Nat) : async CryptoAccount.AccountResult {
    account.deposit(amount)
  };
};
