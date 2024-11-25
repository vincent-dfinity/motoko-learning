import Iter "mo:base/Iter";
import Map "mo:base/OrderedMap";
import Set "mo:base/OrderedSet";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";

actor {
  type Result<T, E> = Result.Result<T, E>;

  type Book = BookModule.Book;
  type BookResult = BookModule.BookResult;
  type FilterBy = BookModule.FilterBy;
  type ProposeBook = BookModule.ProposeBook;

  type ReadingProgress = UserModule.ReadingProgress;
  type User = UserModule.User;
  type UserResult = UserModule.UserResult;

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
      var votes : Nat;
      var comments : Map.Map<Nat, Comment>;
    };

    public type BookResult = {
      id : Nat;
      name : Text;
      description : Text;
      proposer : Principal;
      votes : Nat;
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
        var votes = 0;
        var comments = commentMap.empty<Comment>();
      };

      nextBookID += 1;
      newBook
    };

    public func toBookResult(book : Book) : BookResult {
      {
        id = book.id;
        name = book.name;
        description = book.description;
        proposer = book.proposer;
        votes = book.votes;
        comments = Iter.toArray(commentMap.vals(book.comments));
      };
    };

    public type FilterBy = {
      #ByName : Text;
      #ByDescription : Text;
      #ByProposer: Principal;
      // Could add more filters like 
    };

    public func filterBooks(filter : FilterBy) : Result<[BookResult], Text> {
      func bookFilter(_key : Nat, val : Book) : ?BookResult {
        switch filter {
          case (#ByName(name)) {
            if (Text.contains(val.name, #text name))
              return ?toBookResult(val)
            else
              return null
          };
          case (#ByDescription(description)) {
            if (Text.contains(val.description, #text description))
              return ?toBookResult(val)
            else
              return null
          };
          case (#ByProposer(principal)) {
            if (val.proposer == principal)
              return ?toBookResult(val)
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
  
  let progressMap = Map.Make<Nat>(Nat.compare);

  module UserModule {
    public type ReadingProgress = {
      bookId : Nat;
      progress : Nat8;
    };

    public type User = {
      principal : Principal;
      var proposedBooks : Set.Set<Nat>;
      var progressTracking : Map.Map<Nat, Nat8>;
    };

    public type UserResult = {
      principal : Principal;
      proposedBooks : [Nat];
      progressTracking : [ReadingProgress];
    };

    public func getOrInitializeUser(principal : Principal) : User {
      switch(userMap.get(users, principal)) {
        case null {
          {
            principal = principal;
            var proposedBooks = bookSet.empty();
            var progressTracking = progressMap.empty<Nat8>();
          }
        };
        case (?user){
          user
        };
      }
    };

    public func toUserResult(user : User) : UserResult {
      func filter(key : Nat, val : Nat8) : ReadingProgress {
        {
          bookId = key;
          progress = val;
        }
      };

      // Should we store ReadingProgress type instead of the progress Nat8 in User.progressTracking?
      // It would save the map here.
      let resMap = progressMap.map(user.progressTracking, filter);
      {
        principal = user.principal;
        proposedBooks = Iter.toArray(bookSet.vals(user.proposedBooks));
        progressTracking = Iter.toArray(progressMap.vals(resMap));
      }
    }
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

  public shared ({ caller }) func proposeBook(book : ProposeBook) : async Result<Nat, Text>{
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to propose.");
    };

    // Simply use a generated book id as the key.
    let newBook = BookModule.initializeBook(book, caller);
    books := bookMap.put(books, newBook.id, newBook);

    // Register user.
    let user = UserModule.getOrInitializeUser(caller);
    user.proposedBooks := bookSet.put(user.proposedBooks, newBook.id);
    users := userMap.put(users, caller, user);

    #ok(newBook.id)
  };

  public query func getBookById(id : Nat) : async Result<BookResult, Text> {
    switch(bookMap.get(books, id)) {
      case null #err("Book with id " # Nat.toText(id) # " does not exist.");
      case (?book) #ok(BookModule.toBookResult(book));
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
        book.votes += 1;
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

  public query func getUserByPrincipal(principal : Principal) : async Result<UserResult, Text> {
    // Now everyone can check any user information, we can add the check easily if it's necessary.
    let ?user = userMap.get(users, principal) else return #err("User with principal " # Principal.toText(principal) # " does not exist.");
    #ok(UserModule.toUserResult(user))
  };

  public shared ({ caller }) func updateReadingProgressOnBook(progress : ReadingProgress) : async Result<Bool, Text> {
    if (Principal.isAnonymous(caller)) {
      return #err("An anonymous user is not allowed to update reading progress.");
    };

    let user = UserModule.getOrInitializeUser(caller);
    user.progressTracking := progressMap.put(user.progressTracking, progress.bookId, progress.progress);

    #ok(true)
  };
};
