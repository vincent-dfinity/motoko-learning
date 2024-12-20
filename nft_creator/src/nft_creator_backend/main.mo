import Error "mo:base/Error";
import Map "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";

actor class NFTCreateor(
  initArgs : {
    mintingAccount : Principal
  }
) {
  public type Token = {
    id : Nat;
    name : Text;
    description : Text;
    image : Text;
    owner : Principal
  };

  public type MintingArgs = {
    to : Principal;
    name : Text;
    description : Text;
    image : Text // A URL to an image.
  };

  public type BurningArgs = {
    id : Nat;
  };

  var mintingAccount : Principal = initArgs.mintingAccount;
  var nextTokenId : Nat = 0;
  
  let natMap = Map.Make<Nat>(Nat.compare);
  var tokens : Map.Map<Nat, Token> = natMap.empty<Token>();

  private func initializeToken(mintArgs : MintingArgs) : Token {
    let newToken = {
      id = nextTokenId;
      name = mintArgs.name;
      description = mintArgs.description;
      image = mintArgs.image; // Could check if the image is a valid URL.
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

  public shared ({ caller }) func mint(mintArgs : MintingArgs) : async Nat {
    if (caller != mintingAccount) {
      throw Error.reject("Only the minting account is allowed to mint a NFT token.");
    };

    let token = initializeToken(mintArgs);
    tokens := natMap.put(tokens, token.id, token);

    token.id
  };

  public query func getToken(id : Nat) : async Token {
    switch (natMap.get(tokens, id)) {
      case null throw Error.reject("Token with id " # Nat.toText(id) # " does not exist.");
      case (?token) token
    }
  };

  public shared ({ caller }) func burn(burnArgs : BurningArgs) : async Bool {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous caller is not allowed to burn a token.")
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
  }
};
