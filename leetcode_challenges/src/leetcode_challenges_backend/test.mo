import Solution "canister:leetcode_challenges_backend";

actor Test {
  public composite query func testSqrt() : async () {
    assert( (await Solution.sqrt(0)) == 0);
    assert( (await Solution.sqrt(1)) == 1);
    assert( (await Solution.sqrt(3)) == 1);
    assert( (await Solution.sqrt(4)) == 2);
    assert( (await Solution.sqrt(8)) == 2);
    assert( (await Solution.sqrt(9)) == 3);
  };

  public composite query func testRotateList() : async () {
    let array : [Nat] = [1, 2, 3, 4, 5];
    let array_k1 : [Nat] = [5, 1, 2, 3, 4];
    let array_k3 : [Nat] = [3, 4, 5, 1, 2];
    assert( (await Solution.rotateList(array, 0)) == array);
    assert( (await Solution.rotateList(array, 1)) == array_k1);
    assert( (await Solution.rotateList(array, 3)) == array_k3);
    assert( (await Solution.rotateList(array, 5)) == array);
    assert( (await Solution.rotateList(array, 6)) == array_k1);
  };
};
