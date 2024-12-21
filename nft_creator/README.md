# NFT Creator

A simple sample of a NFT creator to show how to mint, burn NFTs.

## How to interact

1. dfx new identity minter
1. dfx new identity first
1. dfx start --clean --background
1. dfx deploy nft_creator_backend --argument "(record { \
  mintingAccount = principal \"$(dfx identity get-principal --identity minter)\";\
  symbol = \"MFNC\";\
  name = \"My First NFT Collection\";\
  description = \"This is my first NFT collection.\";\
  logo = \"https://images.google.com\";\
  supplyCap = 20;\
  maxQueryBatchSize = 5;\
  maxUpdateBatchSize = 5;\
})"
1. dfx canister call nft_creator_backend getMintingAccount
1. dfx canister call nft_creator_backend getCollectionMetadata
1. dfx canister call nft_creator_backend mint "(record { to = principal \"$(dfx identity get-principal)\"; name = \"My token 0\"; description = \"This is my first NFT token\"; logo = \"https://images.google.com\" })" --identity minter
1. dfx canister call nft_creator_backend mint "(record { to = principal \"$(dfx identity get-principal)\"; name = \"My token 1\"; description = \"This is my second NFT token\"; logo = \"https://images.google.com\" })" --identity minter
1. dfx canister call nft_creator_backend getTokens "(vec {0; 1})"
1. dfx canister call nft_creator_backend getTokenOwnerOf "(vec {0; 1})"
1. dfx canister call nft_creator_backend getTokensOf "principal \"$(dfx identity get-principal)\""
1. dfx canister call nft_creator_backend getBalanceOf "principal \"$(dfx identity get-principal)\""
1. dfx canister call nft_creator_backend getTokenMetadata "(vec {0; 1})"
1. dfx canister call nft_creator_backend burn "(record { id = 0})"
1. dfx canister call nft_creator_backend transfer "(record { to = principal \"$(dfx identity get-principal --identity first)\"; tokenId = 1 })"
1. dfx canister call nft_creator_backend getTxLogs "(vec {0; 1; 2; 3; 4;})"
