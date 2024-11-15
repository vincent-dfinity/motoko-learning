import IC "mo:base/ExperimentalInternetComputer";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

actor Main {
  public query func test() : async Text {
    let encoding : Blob = to_candid ("dog", #are, ['g', 'r', 'e', 'a', 't']);

    let ?(t, v, cs) = from_candid(encoding) : ?(Text, {#are; #are_not}, [Char]) else return "Failed to deserialize candid.";
    debug_show(t, v, cs)
  };

  public func concat(texts : [Text]) : async Text {
    var result = "";

    for (text in texts.vals()) {
      result #= text;
    };

    result
  };

  public func test1() : async Text {
    let args = to_candid(["a", "b", "c"]);

    // IC system takes care of converting serialzied Blob into a Text array for `concat` function.
    let result = await IC.call(Principal.fromActor(Main), "concat", args);
    
    // Now result is a Text rather than Text array.
    let ?parsedArgs = from_candid(result) : ?Text else return "Failed to deserialize candid.";
    parsedArgs
  };
};
