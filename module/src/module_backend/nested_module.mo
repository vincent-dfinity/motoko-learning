module {
  public module Person {
    public let name = "Peter";
    public let age = 20 : Nat;
  };

  private module Info {
    public let city = "Zurich";
  };

  public let place = Info.city;

  public func checkAge(age : Nat) : Bool {
    age >= 18
  };
};
