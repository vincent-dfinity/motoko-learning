# Voting System

An example of a decentralized voting system in Motoko where users (Principals) can create simple yes/no polls and cast their votes.

## How to interact

1. dfx start --clean --background
1. dfx deploy
1. dfx canister call voting-system-backend createYesOrNoPoll '(record {title="My poll"; description="Do you agree on that the Earth is flat?"})'
1. dfx canister call voting-system-backend createYesOrNoPoll '(record {title="My poll 1"; description="Do you agree on that the Earth is flat?"})'
1. dfx canister call voting-system-backend getPoll '0'
1. dfx canister call voting-system-backend getAllPolls
1. dfx canister call voting-system-backend getPollByPrincipal
1. dfx canister call voting-system-backend voteOnPoll '(0, 1)'
1. dfx canister call voting-system-backend closePoll '0'
1. dfx canister call voting-system-backend createMultiChoicesPoll '(record {title="My poll 2"; description="Do you agree on that the Earth is flat?"; options=vec {"yes"; "no"; "not sure"}})'
1. dfx canister call voting-system-backend voteOnPoll '(2, 2)'
