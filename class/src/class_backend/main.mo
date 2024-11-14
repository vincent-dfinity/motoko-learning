import CryptoAccount "CryptoAccount";

actor {
  let account = CryptoAccount.CryptoAccount(100);

  public query func getAccountBalance() : async Nat {
    account.balance
  };

  public func accountPay(amount : Nat) : async CryptoAccount.PayResult {
    account.pay(amount)
  };
};
