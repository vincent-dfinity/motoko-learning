shared(msg) actor class Counter(initValue: Nat) {
    let owner = msg.caller;

    var count = initValue;

    public shared(msg) func inc() : async () {
        assert(owner == msg.caller);
        count += 1;
    };

    public func read() : async Nat {
        count
    };

    public shared(msg) func reset() : async Nat {
        assert (owner == msg.caller);
        count := 1;
        count;
    }
}
