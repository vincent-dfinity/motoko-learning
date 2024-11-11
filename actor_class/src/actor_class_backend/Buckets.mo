import Nat "mo:base/Nat";
import Map "mo:base/RBTree";

actor class Bucket(num : Nat, index : Nat) {
    type Key = Nat;
    type Value = Text;

    let map = Map.RBTree<Key, Value>(Nat.compare);

    public func get(key: Key) : async ?Value {
        assert((key % num) == index);

        map.get(key);
    };

    public func put(key : Key, value : Value) : async () {
        assert((key % num) == index);

        map.put(key, value);
    };
};
