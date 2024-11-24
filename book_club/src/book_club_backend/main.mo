import Iter "mo:base/Iter";
import Map "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

actor {
  type Result<T, E> = Result.Result<T, E>;

  public type Book = {
    id : Nat;
    name : Text;
    description : Text;
    proposer : Principal;
    thumbUp : Nat;
    thumbDown : Nat;
  };

  public type CreateBook = {
    name : Text;
    description : Text;
  };

  let bookMap = Map.Make<Nat>(Nat.compare);
  var books : Map.Map<Nat, Book> = bookMap.empty<Book>();

  var nextBookID : Nat = 0;
  private func createBook(book : CreateBook, p : Principal) : Book {
    let newBook = {
      id = nextBookID;
      name = book.name;
      description = book.description;
      proposer = p;
      thumbUp = 0;
      thumbDown = 0;
    };

    nextBookID += 1;
    newBook
  };

  public shared ({ caller }) func proposeBook(book : CreateBook) : async Result<Nat, Text>{
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to propose.");
    };

    // Simply use a generated book id as the key.
    let newBook = createBook(book, caller);
    books := bookMap.put(books, newBook.id, newBook);
    #ok(newBook.id)
  };

  public query func getBookById(id : Nat) : async Result<Book, Text> {
    switch(bookMap.get(books, id)) {
      case null #err("Book with id " # Nat.toText(id) # " does not exist.");
      case (?book) #ok(book);
    }
  };

  type FilterBy = {
    #ByName : Text;
    #ByDescription : Text;
    #ByProposer: Principal;
  };

  private func filterBooks(filter : FilterBy) : Result<[Book], Text> {
    func bookFilter(_key : Nat, val : Book) : ?Book {
      switch filter {
        case (#ByName(name)) {
          if (Text.contains(val.name, #text name))
            return ?val
          else
            return null
        };
        case (#ByDescription(description)) {
          if (Text.contains(val.description, #text description))
            return ?val
          else
            return null
        };
        case (#ByProposer(principal)) {
          if (val.proposer == principal)
            return ?val
          else
            return null
        };
      }
    };

    let newMap = bookMap.mapFilter(books, bookFilter);

    if (bookMap.size(newMap) == 0) {
      return #err("Book with " # debug_show(filter) # " does not exist.")
    };

    #ok(Iter.toArray(bookMap.vals(newMap)))
  };

  public query func getBooksByName(name : Text) : async Result<[Book], Text> {
    filterBooks(#ByName(name))
  };

  public query func getBooksByDescription(description : Text) : async Result<[Book], Text> {
    filterBooks(#ByDescription(description))
  };

  public query func getBooksByProposer(proposer : Principal) : async Result<[Book], Text> {
    filterBooks(#ByProposer(proposer))
  };
};
