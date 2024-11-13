import Buffer "mo:base/Buffer";

actor {
  let goals = Buffer.Buffer<Text>(0);

  public func addGoal(goal : Text) : async () {
    goals.add(goal);
  };

  // This won't compile as Buffer<Text> is mutable and is not a shared type.
  // public func getGoals() : async Buffer.Buffer<Text> { 
  public func getGoals() : async [Text] {
    return Buffer.toArray(goals);
  }
};
