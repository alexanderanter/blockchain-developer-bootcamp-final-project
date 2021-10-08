# blockchain-developer-bootcamp-final-project

buyTogether:

The Problem: Crypto is volatile, GAS fees are high, Centralized exchanges is similar to a bank and the reason crypto exists in the first place.
Solution: An affordable way to buy up crypto with small amounts on a regular(semi-regular) basis.

Buying small amounts of crypto on a regular basis costs too much in gas fees its not worth it,
by pooling together with others so the small purchases becomes big ones, users can save a lot on gas fees and also, instead of 100 people remembering to
make 100 transactions every month, 1 user can do it for all 100.



1. Alice deposit DAI to their connected wallet through metamask
2. Smart contract updates the total dai deposited and makes note of how much Alice deposited
3. Owner triggers a function that converts a small amount deposited DAI to WETH that only owner can trigger.
5. Alice decides to withdraw ALL the current WETH she got right to, 
6. totalDAI deposited updates as well as the DAIdeposited Alice have put in 
7. claimable WETH for Alice goes to 0
8. Owner triggers a function that converts a small amount deposited DAI to WETH that only owner can trigger.
9. Alice claimable WETH goes up again but this time the % of the total weth bought is less because she already cashed out once and smaller % of the pool!



Future:
implement a check so the owner cant do too many frequent conversion
add all users to the owner multisig so any user can trigger a conversion (if its not too soon!)


Create a incentivised mechanism for users to manage and trigger the conversion on a regular basis

To protect if the owner dies:
Implement a fail-safe so if the Owner have not converted for serious long time (store blocktime of each conversion and compare it with current when trigger), any user can trigger a convertALLDAI function so all users can convert. Or simply create a votefunction so if enough users vote to convertALL, it converts!
Can also be useful if ETH crashes in value and all users want to buy for everything at once.



Implement chainlink oracle to do this on a regular basis instead of relying on a owner that does this. 
