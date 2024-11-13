import Debug "mo:base/Debug";
import Timer "mo:base/Timer";

actor {
  var timerId : Timer.TimerId = 0;

  private func log () : async () {
    Debug.print("Only once!");
  };

  private func recurringLog () : async () {
    Debug.print("Recurring!");
  };

  public func setTimer () : async () {
    ignore Timer.setTimer<system>(#seconds 10, log);
  };

  public func setRecurringTimer () : async () {
    timerId := Timer.recurringTimer<system>(#seconds 10, recurringLog);
  };

  public func cancelRecurringTimer () : async () {
    Timer.cancelTimer(timerId);
  }
};
