import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Map "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Array "mo:base/Array";

actor class NFTCreateor(
  initArgs : {
    mintingAccount : Principal;
    symbol : Text;
    name : Text;
    description : Text;
    logo : Text;
    supplyCap : Nat;
    maxQueryBatchSize : Nat;
    maxUpdateBatchSize : Nat;
  }
) {
  public type Token = {
    id : Nat;
    name : Text;
    description : Text;
    logo : Text;
    owner : Principal
  };

  public type Value = {
    #Blob : Blob;
    #Text : Text;
    #Nat : Nat;
    #Int : Int;
    #Array : [Value];
    #Map : [(Text, Value)]
  };

  public type MintingArgs = {
    to : Principal; // Could add subaccount support in the future.
    name : Text;
    description : Text;
    logo : Text // A URL to an image.
  };

  public type BurningArgs = {
    id : Nat;
  };

  var mintingAccount = initArgs.mintingAccount;
  let symbol = initArgs.symbol;
  let name = initArgs.name;
  let description = initArgs.description;
  let logo = initArgs.logo;
  let supplyCap = initArgs.supplyCap;
  let maxQueryBatchSize = initArgs.maxQueryBatchSize;
  let maxUpdateBatchSize = initArgs.maxUpdateBatchSize;

  stable var nextTokenId : Nat = 0;
  
  let textMap = Map.Make<Text>(Text.compare);

  let natMap = Map.Make<Nat>(Nat.compare);
  stable var tokens : Map.Map<Nat, Token> = natMap.empty<Token>();

  private func initializeToken(mintArgs : MintingArgs) : Token {
    let newToken = {
      id = nextTokenId;
      name = mintArgs.name;
      description = mintArgs.description;
      logo = mintArgs.logo; // Could check if it is a valid URL.
      owner = mintArgs.to;
    };

    nextTokenId += 1;
    newToken
  };

  public query func getMintingAccount() : async Principal {
    mintingAccount
  };

  public shared ({ caller }) func setMintingAccount(principal : Principal) : async Bool {
    if (not Principal.isController(caller)) {
      throw Error.reject("Only the controllers are allowed to set the minting account.");
    };

    if (Principal.isAnonymous(principal)) {
      throw Error.reject("The minting account cannot be anonymous.");
    };

    mintingAccount := principal;

    true
  };

  public query func getSymbol() : async Text {
    symbol
  };

  public query func getName() : async Text {
    name
  };

  public query func getDescription() : async ?Text {
    ?description
  };

  public query func getLogo() : async ?Text {
    ?logo
  };

  public query func getTotalSupply() : async Nat {
    nextTokenId
  };

  public query func getSupplyCap() : async ?Nat {
    ?supplyCap
  };

  public query func getCollectionMetadata() : async [(Text, Value)] {
    var metadata : Map.Map<Text, Value> = textMap.empty<Value>();

    metadata := textMap.put(metadata, "Symbol", #Text(symbol));
    metadata := textMap.put(metadata, "Name", #Text(name));
    metadata := textMap.put(metadata, "Logo", #Text(logo));
    metadata := textMap.put(metadata, "Description", #Text(description));
    metadata := textMap.put(metadata, "SupplyCap", #Nat(supplyCap));
    metadata := textMap.put(metadata, "MaxQueryBatchSize", #Nat(maxQueryBatchSize));
    metadata := textMap.put(metadata, "MaxUpdateBatchSize", #Nat(maxUpdateBatchSize));

    Iter.toArray(textMap.entries(metadata))
  };

  public shared ({ caller }) func mint(mintArgs : MintingArgs) : async Nat {
    if (caller != mintingAccount) {
      throw Error.reject("Only the minting account is allowed to mint a NFT token.");
    };

    let token = initializeToken(mintArgs);
    tokens := natMap.put(tokens, token.id, token);

    token.id
  };

  public shared ({ caller }) func burn(burnArgs : BurningArgs) : async Bool {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous principal is not allowed to burn a token.")
    };

    if (caller == mintingAccount) {
      throw Error.reject("Cannot burn with the minting account.")
    };

    let ?token = natMap.get(tokens, burnArgs.id) else throw Error.reject("Poll with id " # Nat.toText(burnArgs.id) # " does not exist.");
    if (caller != token.owner) {
      throw Error.reject("Only the owner can burn this token.")
    };

    // Transfer token to the minting account as the buring operation.
    let tempToken = {
      token with owner = mintingAccount
    };

    let (tempTokens, _) = natMap.replace(tokens, token.id, tempToken);
    tokens := tempTokens;

    true
  };

  public query func getTokens(ids : [Nat]) : async [?Token] {
    if (ids.size() > maxQueryBatchSize) {
      throw Error.reject("Exceeds the maximum query batch size " # Nat.toText(maxQueryBatchSize))
    };

    Array.map<Nat, ?Token> (
      ids,
      func id {
        switch (natMap.get(tokens, id)) {
          case null null;
          case (?token) ?token
        }
      }
    )
  };

  public query func getTokensOf(principal : Principal) : async [Token] {
    if (Principal.isAnonymous(principal)) {
      throw Error.reject("An anonymous principal is not allowed to owner tokens.")
    };

    func filter(_key : Nat, val : Token) : ?Token {
      if (val.owner == principal) ?val else null
    };

    let newMap = natMap.mapFilter(tokens, filter);
    Iter.toArray(natMap.vals(newMap))
  };

  public query func getBalanceOf(principal : Principal) : async Nat {
    if (Principal.isAnonymous(principal)) {
      throw Error.reject("An anonymous principal is not allowed to owner tokens.")
    };

    var count = 0;
    for ((_key, val) in natMap.entries(tokens)) {
      if (val.owner == principal) {
        count += 1;
      }
    };
    count
  };

  public query func getTokenOwnerOf(ids : [Nat]) : async [?Principal] {
    if (ids.size() > maxQueryBatchSize) {
      throw Error.reject("Exceeds the maximum query batch size " # Nat.toText(maxQueryBatchSize))
    };

    Array.map<Nat, ?Principal> (
      ids,
      func id {
        switch (natMap.get(tokens, id)) {
          case null null;
          case (?token) ?token.owner
        }
      }
    )
  };

  public query func getTokenMetadata(ids : [Nat]) : async [?[(Text, Value)]] {
    if (ids.size() > maxQueryBatchSize) {
      throw Error.reject("Exceeds the maximum query batch size " # Nat.toText(maxQueryBatchSize))
    };

    Array.map<Nat, ?[(Text, Value)]>(
      ids,
      func id {
        switch (natMap.get(tokens, id)) {
          // Trap if the id doesn't exist, could be improved to skip the invalid ids wit Array.mapFilter.
          case null null;
          case (?token) {
            var metadata : Map.Map<Text, Value> = textMap.empty<Value>();

            metadata := textMap.put(metadata, "Name", #Text(token.name));
            metadata := textMap.put(metadata, "Logo", #Text(token.logo));
            metadata := textMap.put(metadata, "Description", #Text(token.description));

            ?Iter.toArray(textMap.entries(metadata))
          }
        }
      }
    )
  }
};
