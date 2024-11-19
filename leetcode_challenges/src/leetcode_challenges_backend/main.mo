import List "mo:base/List";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Order "mo:base/Order";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";

actor {
  public func test() : async Text {
    let array : [Nat] = [2, 4, 1, 0, 3, 5];
    let rotatedArray = await rotateList(array);
    debug_show(rotatedArray)
  };

  public query func rotateList(array : [Nat]) : async [Nat] {
    let list = List.fromArray(array);

    // TODO: Rotate arrary.

    List.toArray(list)
  };

  public query func countOneBits (number : Nat64) : async Nat64 {
    var count : Nat64 = 0;
    var num = number;
    let bit = 1 : Nat64;

    while (num > 0) {
      count += num & bit;
      num >>= 1;
    };

    count
  };

  public query func reverseBits(number : Nat64) : async Nat64 {
    let size : Nat = 64;

    var rev : Nat64 = 0;
    var num = number;

    for(index in Iter.range(0, size -1)) {
      rev <<= 1;
      
      if (num & 1 == 1) {
        rev ^= 1;
      };

      num >>= 1;
    };

    rev
  };

  private func find(sortedArray : [Int], value : Int, order : Order) : ?Nat {
    var low : Int = 0;
    var high : Int = sortedArray.size() - 1;

    var result : ?Nat = null;
    while (low <= high) {
      let mid : Int = low + (high - low) / 2;
      let index = Int.abs(mid);

      if (sortedArray[index] > value) {
        high := mid - 1;
      }
      else if (sortedArray[index] < value) {
        low := mid + 1;
      }
      else {
        result := ?index;
        switch order {
          case (#First) { high := mid - 1 };
          case (#Last) { low := mid + 1 };
        };
      }
    };

    result
  };

  type Order = {
    #First;
    #Last;
  };

  public query func findFirstandLast(sortedArray : [Int], value : Int) : async (?Nat, ?Nat) {
    if (sortedArray.size() == 0) {
      return (null, null);
    };

    (find(sortedArray, value, #First), find(sortedArray, value, #Last))
  };

  public query func sqrt(number : Nat64) : async Nat64 {
    var result = number >> 1;
    if (result == 0) {
      return number;
    };

    var nextResult = (result + number / result) >> 1;
    while (nextResult < result) {
      result := nextResult;
      nextResult := (result + number / result) >> 1;
    };

    return result;
  };
};
