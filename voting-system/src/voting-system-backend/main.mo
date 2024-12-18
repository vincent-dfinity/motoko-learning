import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Map "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Set "mo:base/OrderedSet";
import Float "mo:base/Float";

actor {
  type Poll = PollModule.Poll;
  type PollOption = PollModule.PollOption;
  type CreateYesOrNoPoll = PollModule.CreateYesOrNoPoll;
  type CreatePoll = PollModule.CreatePoll;
  type PollResult = PollModule.PollResult;
  type PollStatistics = PollModule.PollStatistics;

  type User = UserModule.User;

  let natMap = Map.Make<Nat>(Nat.compare);
  let natSet = Set.Make<Nat>(Nat.compare);
  let principalMap = Map.Make<Principal>(Principal.compare);

  stable var nextPollId : Nat = 0;
  stable var polls : Map.Map<Nat, Poll> = natMap.empty<Poll>();

  module PollModule {
    public type PollOption = {
      option : Text;
      var votes : Nat
    };

    public type PollOptionResult = {
      option : Text;
      votes : Nat
    };

    public type CreateYesOrNoPoll = {
      title : Text;
      description : Text
    };

    public type CreatePoll = {
      title : Text;
      description : Text;
      options : [Text]
    };

    public type Poll = {
      id : Nat;
      owner : Principal;
      title : Text;
      description : Text; // Or question?
      options : [PollOption];
      var active : Bool
    };

    public type PollResult = {
      id : Nat;
      owner : Principal;
      title : Text;
      description : Text;
      options : [PollOptionResult];
      active : Bool
    };

    public type PollOptionStatistics = {
      option : Text;
      votes : Nat;
      percentage : Float
    };

    public type PollStatistics = {
      id : Nat;
      owner : Principal;
      title : Text;
      description : Text;
      votesInTotal : Nat;
      options : [PollOptionStatistics];
      active : Bool
    };

    public func initializePoll(owner : Principal, poll : CreatePoll) : Poll {
      let options = Array.map<Text, PollOption>(
        poll.options,
        func option {
          {
            option;
            var votes = 0
          }
        }
      );

      let newPoll = {
        id = nextPollId;
        owner;
        title = poll.title;
        description = poll.description;
        options;
        var active = true
      };

      nextPollId += 1;
      newPoll
    };

    public func toPollResult(poll : Poll) : PollResult {
      let options = Array.map<PollOption, PollOptionResult>(
        poll.options,
        func pollOption {
          {
            option = pollOption.option;
            votes = pollOption.votes
          }
        }
      );

      {
        id = poll.id;
        owner = poll.owner;
        title = poll.title;
        description = poll.description;
        options;
        active = poll.active
      }
    };

    public func toPollStatistics(poll : Poll) : PollStatistics {
      var votesInTotal = 0;
      for (pollOption in poll.options.vals()) {
        votesInTotal += pollOption.votes
      };

      let options = Array.map<PollOption, PollOptionStatistics>(
        poll.options,
        func pollOption {
          {
            option = pollOption.option;
            votes = pollOption.votes;
            percentage = if (votesInTotal == 0) 0 else Float.fromInt(pollOption.votes) / Float.fromInt(votesInTotal) * 100
          }
        }
      );

      {
        id = poll.id;
        owner = poll.owner;
        title = poll.title;
        description = poll.description;
        votesInTotal;
        options;
        active = poll.active
      }
    }
  }; // End PollModule.

  stable var users : Map.Map<Principal, User> = principalMap.empty<User>();

  module UserModule {
    public type User = {
      principal : Principal;
      var polls : Set.Set<Nat>
    };

    public func getOrInitializeUser(principal : Principal) : User {
      switch (principalMap.get(users, principal)) {
        case null {
          {
            principal = principal;
            var polls = natSet.empty()
          }
        };
        case (?user) {
          user
        }
      }
    };

    public func toPollResults(user : User) : [PollResult] {
      let pollIds = natSet.vals(user.polls);
      let tempPolls = Iter.map<Nat, PollResult>(
        pollIds,
        func pollId {
          switch (natMap.get(polls, pollId)) {
            case (?poll) PollModule.toPollResult(poll);
            case null Debug.trap("Poll with id " # Nat.toText(pollId) # " does not exist. This shouldn't happen.")
          }
        }
      );
      Iter.toArray(tempPolls)
    }
  }; // End UserModule.

  public shared ({ caller }) func createYesOrNoPoll(poll : CreateYesOrNoPoll) : async Nat {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to create a poll.")
    };

    let newPoll = PollModule.initializePoll(
      caller,
      { poll with options = ["yes", "no"] }
    );
    polls := natMap.put(polls, newPoll.id, newPoll);

    let user = UserModule.getOrInitializeUser(caller);
    user.polls := natSet.put(user.polls, newPoll.id);
    users := principalMap.put(users, caller, user);

    newPoll.id
  };

  public shared ({ caller }) func createMultiChoicesPoll(poll : CreatePoll) : async Nat {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to create a poll.")
    };

    let newPoll = PollModule.initializePoll(caller, poll);
    polls := natMap.put(polls, newPoll.id, newPoll);

    let user = UserModule.getOrInitializeUser(caller);
    user.polls := natSet.put(user.polls, newPoll.id);
    users := principalMap.put(users, caller, user);

    newPoll.id
  };

  public shared ({ caller }) func closePoll(id : Nat) : async Bool {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to close a poll.")
    };

    let ?poll = natMap.get(polls, id) else throw Error.reject("Poll with id " # Nat.toText(id) # " does not exist.");
    if (caller != poll.owner) {
      throw Error.reject("Only the owner can close the poll.")
    };

    poll.active := false;

    true
  };

  public shared ({ caller }) func deletePoll(id : Nat) : async Bool {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to delete a poll.")
    };

    let ?user = principalMap.get(users, caller) else throw Error.reject("User with principal " # Principal.toText(caller) # " does not exist.");

    let ?poll = natMap.get(polls, id) else throw Error.reject("Poll with id " # Nat.toText(id) # " does not exist.");
    if (caller != poll.owner) {
      throw Error.reject("Only the owner can delete the poll.")
    };

    user.polls := natSet.delete(user.polls, id);
    polls := natMap.delete(polls, id);

    true
  };

  public query func getPoll(id : Nat) : async PollResult {
    // Can add access control in the future, including:
    // 1. normal users can only see the vote options;
    // 2. only the owner can get the votes on each option.

    switch (natMap.get(polls, id)) {
      case null throw Error.reject("Poll with id " # Nat.toText(id) # " does not exist.");
      case (?poll) PollModule.toPollResult(poll)
    }
  };

  public query func getAllPolls() : async [PollResult] {
    // Can add access control in the future, including:
    // 1. normal users can only see the vote options;
    // 2. only the owner can get the votes on each option.

    func pollMap(_key : Nat, val : Poll) : PollResult {
      PollModule.toPollResult(val)
    };

    let newMap = natMap.map(polls, pollMap);
    Iter.toArray(natMap.vals(newMap))
  };

  public shared ({ caller }) func getPollByPrincipal() : async [PollResult] {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to delete a poll.")
    };

    let ?user = principalMap.get(users, caller) else throw Error.reject("User with principal " # Principal.toText(caller) # " does not exist.");
    UserModule.toPollResults(user)
  };

  public func voteOnPoll(id : Nat, index : Nat) : async Bool {
    // Can add access control in the future, including:
    // 1. only allow identified users to vote;
    // 2. only count each user once on an option;
    // 3. vote on multiple options?
    // 4. support devote or revote.

    let ?poll = natMap.get(polls, id) else return throw Error.reject("Poll with id " # Nat.toText(id) # " does not exist.");
    if (not poll.active) {
      throw Error.reject("Poll with id " # Nat.toText(id) # " is not active.")
    };
    if (index >= poll.options.size()) {
      throw Error.reject("Input index " # Nat.toText(index) # " is out of bounds.")
    };

    poll.options[index].votes += 1;

    true
  };

  public shared ({ caller }) func getPollStatistics(id : Nat) : async PollStatistics {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to get the statistics of a poll.")
    };

    let ?poll = natMap.get(polls, id) else return throw Error.reject("Poll with id " # Nat.toText(id) # " does not exist.");
    if (caller != poll.owner) {
      throw Error.reject("Only the owner can get the statistics of a poll.")
    };

    PollModule.toPollStatistics(poll)
  }
}
