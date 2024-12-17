# `book_wishlist`

An example in Motoko where users (Principals) can log books they want to read, with a title and author for each book.


## How to interact

1. dfx start --clean --background
1. dfx deploy
1. dfx canister call book_wishlist_backend addBook '(record {title="My book"; author="Vincent"})'
1. dfx canister call book_wishlist_backend addBook '(record {title="My book 1"; author="Vincent"})'
1. dfx canister call book_wishlist_backend addBook '(record {title="My book 2"; author="Vincent"})'
1. dfx canister call book_wishlist_backend getWishlist
1. dfx canister call book_wishlist_backend getBookById '1'
1. dfx canister call book_wishlist_backend getAllBooks
1. dfx canister call book_wishlist_backend removeBookById '1'
1. dfx canister call book_wishlist_backend updateBookById '(2, record{title="My book 1"; author="Vincent"})'
