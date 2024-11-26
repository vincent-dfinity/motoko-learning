import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Iter "mo:base/Iter";

actor {
  private class Node(value : Int) {
    public var val = value;
    public var next : ?Node = null;
  };

  private func arrayToList(array : [Int]) : Node {
    var head = Node(array[0]);
    var current = head;

    for (index in Iter.range(1, array.size() - 1)) {
      var next = Node(array[index]);
      current.next := ?next;
      current := next;
    };

    head;
  };

  private func listToArray(list : Node) : [Int] {
    // Buffer is only used to convert a linked list to array.
    let array = Buffer.Buffer<Int>(0);

    var current = list;
    array.add(current.val);
    label end loop {
      switch (current.next) {
        case (null) { break end };
        case (?next) {
          array.add(next.val);
          current := next;
        };
      };
    };

    Buffer.toArray(array);
  };

  private func rotate(list : Node, k : Nat) : Node {
    // Get list length.
    var current = list;
    var length : Nat = 1;
    label end loop {
      switch (current.next) {
        case (null) { break end };
        case (?next) {
          length += 1;
          current := next;
        };
      };
    };

    // Make the list a circular list.
    current.next := ?list;

    var step = k % length;
    step := length - step;

    current := list;
    var i = 0;
    label end loop {
      switch (current.next) {
        case (null) { Debug.trap("This should never happen.") };
        case (?next) {
          i += 1;
          if (i == step) {
            break end;
          };
          current := next;
        };
      };
    };

    // Break the circular list.
    let ?newList = current.next else Debug.trap("This should never happen.");
    current.next := null;

    newList;
  };

  // Leetcode 61: https://leetcode.com/problems/rotate-list/
  public query func rotateList(array : [Int], k : Nat) : async [Int] {
    let size = array.size();
    if (size <= 1 or k % size == 0) {
      return array;
    };

    var list = arrayToList(array);
    var rotatedList = rotate(list, k);
    listToArray(rotatedList);
  };

  // Leetcode 191: https://leetcode.com/problems/number-of-1-bits/description/
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

  // Leetcode 190: https://leetcode.com/problems/reverse-bits/description/
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

  private func find(sortedArray : [Int], value : Int, order : SearchOrder) : ?Nat {
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

  type SearchOrder = {
    #First;
    #Last;
  };

  // Leetcode 34: https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/
  public query func findFirstandLast(sortedArray : [Int], value : Int) : async (?Nat, ?Nat) {
    if (sortedArray.size() == 0) {
      return (null, null);
    };

    (find(sortedArray, value, #First), find(sortedArray, value, #Last))
  };

  // Leetcode 69: https://leetcode.com/problems/sqrtx/description/
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
