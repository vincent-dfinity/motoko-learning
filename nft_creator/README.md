# NFT Creator

A simple sample of a NFT creator to show how to mint, burn NFTs.

## How to interact

1. dfx new identity minter
1. dfx start --clean --background
1. dfx deploy nft_creator_backend --argument "(record { mintingAccount = principal \"$(dfx identity get-principal --identity minter)\"})"
1. dfx canister call nft_creator_backend getMintingAccount
1. dfx canister call nft_creator_backend mint "(record { to = principal \"$(dfx identity get-principal)\"; name = \"My token 0\"; description = \"This is my first NFT token\"; image = \"https://images.google.com\" })" --identity minter
1. dfx canister call nft_creator_backend getToken "0"
