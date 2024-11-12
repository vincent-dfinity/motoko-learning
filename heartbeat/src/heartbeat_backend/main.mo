import Debug "mo:base/Debug";

actor Alarm {
  let num = 5;
  var count = 0;

  public shared func ring() : async () {
    Debug.print("Ring!"); // Canister logs.
  };

  system func heartbeat() : async () {
    if (count % num == 0) {
      await ring();
    };

    count += 1;
  };
};
