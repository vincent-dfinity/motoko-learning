import Iter "mo:base/Iter";
import Map "mo:base/OrderedMap";
import Set "mo:base/OrderedSet";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

actor {
  type Result<T, E> = Result.Result<T, E>;

  type Book = BookModule.Book;
  type BookResult = BookModule.BookResult;
  type FilterBy = BookModule.FilterBy;
  type ProposeBook = BookModule.ProposeBook;

  type User = UserModule.User;

  type Comment = CommentModule.Comment;
  type PostComment = CommentModule.PostComment;

  var nextBookID : Nat = 0;
  let bookMap = Map.Make<Nat>(Nat.compare);
  var books : Map.Map<Nat, Book> = bookMap.empty<Book>();

  let commentMap = Map.Make<Nat>(Nat.compare);

  module BookModule {
    public type Book = {
      id : Nat;
      name : Text;
      description : Text;
      proposer : Principal;
      var thumbUp : Nat;
      var comments : Map.Map<Nat, Comment>;
    };

    public type BookResult = {
      id : Nat;
      name : Text;
      description : Text;
      proposer : Principal;
      thumbUp : Nat;
      comments : [Comment];
    };

    public type ProposeBook = {
      name : Text;
      description : Text;
    };

    public func initializeBook(book : ProposeBook, p : Principal) : Book {
      let newBook = {
        id = nextBookID;
        name = book.name;
        description = book.description;
        proposer = p;
        var thumbUp = 0;
        var comments = commentMap.empty<Comment>();
      };

      nextBookID += 1;
      newBook
    };

    public func toReturnedBookType(book : Book) : BookResult {
      {
        id = book.id;
        name = book.name;
        description = book.description;
        proposer = book.proposer;
        thumbUp = book.thumbUp;
        comments = Iter.toArray(commentMap.vals(book.comments));
      };
    };

    public type FilterBy = {
      #ByName : Text;
      #ByDescription : Text;
      #ByProposer: Principal;
    };

    public func filterBooks(filter : FilterBy) : Result<[BookResult], Text> {
      func bookFilter(_key : Nat, val : Book) : ?BookResult {
        switch filter {
          case (#ByName(name)) {
            if (Text.contains(val.name, #text name))
              return ?BookModule.toReturnedBookType(val)
            else
              return null
          };
          case (#ByDescription(description)) {
            if (Text.contains(val.description, #text description))
              return ?BookModule.toReturnedBookType(val)
            else
              return null
          };
          case (#ByProposer(principal)) {
            if (val.proposer == principal)
              return ?BookModule.toReturnedBookType(val)
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
  };

  let userMap = Map.Make<Principal>(Principal.compare);
  var users : Map.Map<Principal, User> = userMap.empty<User>();

  let bookSet = Set.Make<Nat>(Nat.compare);

  module UserModule {
    public type User = {
      principal : Principal;
      var proposedbooks : Set.Set<Nat>;
    };

    public func initializeUser(p : Principal) : User {
      {
        principal = p;
        var proposedbooks = bookSet.empty();
      }
    };
  };

  var nextCommentID : Nat = 0;

  module CommentModule {
    public type Comment = {
      id : Nat;
      commenter : Principal;
      bookId : Nat;
      comment : Text;
    };

    public type PostComment = {
      bookId : Nat;
      comment : Text;
    };

    public func initializeComment(postComment : PostComment, p : Principal) : Comment {
      let newComment = {
        id = nextCommentID;
        commenter = p;
        bookId = postComment.bookId;
        comment = postComment.comment;
      };

      nextCommentID += 1;
      newComment
    };
  };

  // dfx canister call bkyz2-fmaaa-aaaaa-qaaaq-cai proposeBook '(record {name="My book"; description="This is my favourite book."})'
  public shared ({ caller }) func proposeBook(book : ProposeBook) : async Result<Nat, Text>{
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to propose.");
    };

    // Simply use a generated book id as the key.
    let newBook = BookModule.initializeBook(book, caller);
    books := bookMap.put(books, newBook.id, newBook);

    // Register user.
    let user = switch(userMap.get(users, caller)) {
      case null {
        UserModule.initializeUser(caller)
      };
      case (?user){
        user
      };
    };
    user.proposedbooks := bookSet.put(user.proposedbooks, newBook.id);
    users := userMap.put(users, caller, user);

    #ok(newBook.id)
  };

  public query func getBookById(id : Nat) : async Result<BookResult, Text> {
    switch(bookMap.get(books, id)) {
      case null #err("Book with id " # Nat.toText(id) # " does not exist.");
      case (?book) #ok(BookModule.toReturnedBookType(book));
    }
  };

  public query func getBooksByName(name : Text) : async Result<[BookResult], Text> {
    BookModule.filterBooks(#ByName(name))
  };

  public query func getBooksByDescription(description : Text) : async Result<[BookResult], Text> {
    BookModule.filterBooks(#ByDescription(description))
  };

  public query func getBooksByProposer(proposer : Principal) : async Result<[BookResult], Text> {
    BookModule.filterBooks(#ByProposer(proposer))
  };

  public shared ({ caller }) func voteOnBook(id : Nat) : async Result<Bool, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to vote.");
    };

    switch(bookMap.get(books, id)) {
      case null #err("Book with id " # Nat.toText(id) # " does not exist.");
      case (?book) {
        // TODO: Check if the caller has already voted.
        // Also support unvote.
        book.thumbUp += 1;
        #ok(true)
      };
    };
  };

  public shared ({ caller }) func commentOnBook(comment : PostComment) : async Result<Bool, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to comment.");
    };

    let ?book = bookMap.get(books, comment.bookId) else return #err("Book with id " # Nat.toText(comment.bookId) # " does not exist.");
    let newComment = CommentModule.initializeComment(comment, caller);
    book.comments := commentMap.put(book.comments, newComment.id, newComment);

    #ok(true)
  };
};
