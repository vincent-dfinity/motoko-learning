import Array "mo:base/Array";

actor {
  // dfx canister call <canister_id> sort '(vec {2; 4; 1; 0; 3; 5})'
  public query func sort(input : [Int]) : async [Int] {
    let arraySize = Array.size(input);
    if (arraySize < 2) {
      return input
    };

    let varArray = Array.thaw<Int>(input);
    quickSort(varArray, 0, arraySize - 1);
    Array.freeze(varArray)
  };

  // The simple version of quick sort which sorts an Nat array from low to high.
  func quickSort(varArray : [var Int], l : Nat, r : Nat) : () {
    if (l >= r) {
      return ()
    };

    // Partition.
    let p = partition(varArray, l, r);

    // Sort the left and right partition recursively.
    quickSort(varArray, l, p -1);
    quickSort(varArray, p + 1, r);
  };

  func partition(varArray : [var Int], l : Nat, r : Nat) : Nat {
    var pivot = varArray[l];
    var left = l;
    var right = r;

    while (left < right) {
      while (left < right and varArray[right] >= pivot) {
        // Find the first value that is smaller than the pivot, from right to left.
        right -= 1;
      };
      while (left < right and varArray[left] <= pivot) {
        // Find the first value that is larger than the pivot, from left to right.
        left += 1;
      };
      
      if (left <= right) {
        // Swap the values.
        let swap = varArray[left];
        varArray[left] := varArray[right];
        varArray[right] := swap;
      };
    };

    // Swap the pivot.
    varArray[l] := varArray[left];
    varArray[left] := pivot;

    left
  }
};
