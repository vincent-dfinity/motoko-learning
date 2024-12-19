import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Map "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Set "mo:base/OrderedSet";

actor {
  type Book = BookModule.Book;
  type BookInfo = BookModule.BookInfo;
  type User = UserModule.User;

  let natMap = Map.Make<Nat>(Nat.compare);
  let natSet = Set.Make<Nat>(Nat.compare);
  let principalMap = Map.Make<Principal>(Principal.compare);

  stable var nextBookID : Nat = 0;
  stable var books : Map.Map<Nat, Book> = natMap.empty<Book>();

  module BookModule {
    public type Book = {
      id : Nat;
      title : Text;
      author : Text
    };

    public type BookInfo = {
      title : Text;
      author : Text
    };

    public type RemoveBook = {
      id : Nat
    };

    public func initializeBook(book : BookInfo) : Book {
      let newBook = { book with id = nextBookID };

      nextBookID += 1;
      newBook
    }
  }; // End BookModule.

  stable var users : Map.Map<Principal, User> = principalMap.empty<User>();

  module UserModule {
    public type User = {
      principal : Principal;
      var wishlist : Set.Set<Nat>
    };

    public func toBooks(user : User) : [Book] {
      let bookIds = natSet.vals(user.wishlist);
      let tempBooks = Iter.map<Nat, Book>(
        bookIds,
        func bookId {
          switch (natMap.get(books, bookId)) {
            case (?book) book;
            case null Debug.trap("Book with id " # Nat.toText(bookId) # " does not exist. This shouldn't happen.")
          }
        }
      );
      Iter.toArray(tempBooks)
    };

    public func getOrInitializeUser(principal : Principal) : User {
      switch (principalMap.get(users, principal)) {
        case null {
          {
            principal = principal;
            var wishlist = natSet.empty()
          }
        };
        case (?user) {
          user
        }
      }
    }
  }; // End UserModule.

  public shared ({ caller }) func addBook(book : BookInfo) : async Nat {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to add book.")
    };

    let newBook = BookModule.initializeBook(book);
    books := natMap.put(books, newBook.id, newBook);

    let user = UserModule.getOrInitializeUser(caller);
    user.wishlist := natSet.put(user.wishlist, newBook.id);
    users := principalMap.put(users, caller, user);

    newBook.id
  };

  public query func getAllBooks() : async [Book] {
    Iter.toArray(natMap.vals(books))
  };

  public query func getBookById(id : Nat) : async Book {
    let ?book = natMap.get(books, id) else throw Error.reject("Book with id " # Nat.toText(id) # " does not exist.");
    book
  };

  public shared ({ caller }) func removeBookById(id : Nat) : async Bool {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to remove book.")
    };

    if (not natMap.contains(books, id)) {
      throw Error.reject("Book with id " # Nat.toText(id) # " does not exist.")
    };

    let ?user = principalMap.get(users, caller) else throw Error.reject("User with principal " # Principal.toText(caller) # " does not exist.");

    if (not natSet.contains(user.wishlist, id)) {
      throw Error.reject("Book " # Nat.toText(id) # " is not in the wishlist of user " # Principal.toText(caller) # ".")
    };

    user.wishlist := natSet.delete(user.wishlist, id);
    books := natMap.delete(books, id);

    true
  };

  public shared ({ caller }) func updateBookById(id : Nat, book : BookInfo) : async Bool {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to remove book.")
    };

    if (not natMap.contains(books, id)) {
      throw Error.reject("Book with id " # Nat.toText(id) # " does not exist.")
    };

    let ?user = principalMap.get(users, caller) else throw Error.reject("User with principal " # Principal.toText(caller) # " does not exist.");

    if (not natSet.contains(user.wishlist, id)) {
      throw Error.reject("Book " # Nat.toText(id) # " is not in the wishlist of user " # Principal.toText(caller) # ".")
    };

    let updatedBook = { book with id };
    books := natMap.put(books, id, updatedBook);

    true
  };

  public shared ({ caller }) func getWishlist() : async [Book] {
    if (Principal.isAnonymous(caller)) {
      throw Error.reject("An anonymous user is not allowed to get wishlist.")
    };

    let ?user = principalMap.get(users, caller) else throw Error.reject("User with principal " # Principal.toText(caller) # " does not exist.");

    UserModule.toBooks(user)
  }
}
