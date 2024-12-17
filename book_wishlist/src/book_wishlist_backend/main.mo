import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Map "mo:base/OrderedMap";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Set "mo:base/OrderedSet";

actor {
  type Result<T, E> = Result.Result<T, E>;
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
      author : Text;
    };

    public type BookInfo = {
      title : Text;
      author : Text;
    };

    public type RemoveBook = {
      id : Nat;
    };

    public func initializeBook(book : BookInfo) : Book {
      let newBook = {
        id = nextBookID;
        title = book.title;
        author = book.author;
      };

      nextBookID += 1;
      newBook;
    };
  }; // End BookModule.
  
  stable var users : Map.Map<Principal, User> = principalMap.empty<User>();

  module UserModule {
    public type User = {
      principal : Principal;
      var wishlist : Set.Set<Nat>;
    };

    public func toBooks(user : User) : [Book] {
      var bookList = List.nil<Book>();

      // Iterate in reverse order as List.push pushes to the head.
      for (bookId in natSet.valsRev(user.wishlist)) {
        switch (natMap.get(books, bookId)) {
          case null Debug.print("Book with id " # Nat.toText(bookId) # " does not exist. This shouldn't happen.");
          case (?book) bookList := List.push<Book>(book, bookList);
        };
      };

      List.toArray<Book>(bookList)
    };

    public func getOrInitializeUser(principal : Principal) : User {
      switch (principalMap.get(users, principal)) {
        case null {
          {
            principal = principal;
            var wishlist = natSet.empty();
          };
        };
        case (?user) {
          user;
        };
      };
    };
  }; // End UserModule.

  public shared ({ caller }) func addBook(book : BookInfo) : async Result<Nat, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to add book.");
    };

    let newBook = BookModule.initializeBook(book);
    books := natMap.put(books, newBook.id, newBook);

    let user = UserModule.getOrInitializeUser(caller);
    user.wishlist := natSet.put(user.wishlist, newBook.id);
    users := principalMap.put(users, caller, user);

    #ok(newBook.id);
  };

  public query func getAllBooks() : async Result<[Book], Text> {
    #ok(Iter.toArray(natMap.vals(books)))
  };

  public query func getBookById(id : Nat) : async Result<Book, Text> {
    switch (natMap.get(books, id)) {
      case null #err("Book with id " # Nat.toText(id) # " does not exist.");
      case (?book) #ok(book);
    };
  };

  public shared ({ caller }) func removeBookById(id : Nat) : async Result<Bool, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to remove book.");
    };

    if (not natMap.contains(books, id)) {
      return #err("Book with id " # Nat.toText(id) # " does not exist.");
    };

    let ?user = principalMap.get(users, caller) else return #err("User with principal " # Principal.toText(caller) # " does not exist.");

    if (not natSet.contains(user.wishlist, id)) {
      return #err("Book " # Nat.toText(id) # " is not in the wishlist of user " # Principal.toText(caller) # ".");
    };
    
    user.wishlist := natSet.delete(user.wishlist, id);
    books := natMap.delete(books, id);

    return #ok(true);
  };

  public shared ({ caller }) func updateBookById(id : Nat, book : BookInfo) : async Result<Bool, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to remove book.");
    };

    if (not natMap.contains(books, id)) {
      return #err("Book with id " # Nat.toText(id) # " does not exist.");
    };

    let ?user = principalMap.get(users, caller) else return #err("User with principal " # Principal.toText(caller) # " does not exist.");

    if (not natSet.contains(user.wishlist, id)) {
      return #err("Book " # Nat.toText(id) # " is not in the wishlist of user " # Principal.toText(caller) # ".");
    };

    let updatedBook = {
      id = id;
      title = book.title;
      author = book.author;
    };
    books := natMap.put(books, id, updatedBook);

    #ok(true)
  };

  public shared ({ caller }) func getWishlist() : async Result<[Book], Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to add book.");
    };

    let ?user = principalMap.get(users, caller) else return #err("User with principal " # Principal.toText(caller) # " does not exist.");

    #ok(UserModule.toBooks(user))
  };
};
