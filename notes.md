# blockchain-developer-bootcamp-final-project


buyTogether:


The Problem: Crypto is volatile, GAS fees are high, Centralized exchanges is similar to a bank and the reason crypto exists in the first place.
Solution: An affordable way to buy up crypto with small amounts on a regular basis.

Buying small amounts of crypto on a regular basis costs too much in gas fees its not worth it,
by pooling together so the small purchases becomes big ones and users can later on withdraw all their WETH.



1. Alice deposit DAI to their connected wallet through metamask
2. Smart contract updates the daibalances mapping and total dai deposited
3. Owner triggers a function that converts a small amount deposited DAI to WETH
4. usedDai mapping that keeps track of how much of each users DAI have been used updates (by dividing depositedDAI with the totalDAI times usedDAi in the conversion)
5. Alice decides to withdraw the current WETH she got right to, 
6. totalDAI deposited updates, 
7. claimableWeth for Alice goes to 0
8. depositedDAI decreases by removing the amount of DAI thats been used from Alice initial deposit to buy weth.
9. totalDAI decreases by removing the amount of DAI thats been used from Alice initial deposit to buy weth


DCA smart contract

The problem:

A lot of people want to get into crypto but the market is so volatile that there is a high risk of having bad timing.
In tradtional centralized platforms this is a common and very useful feature for users to setup, however its not available in the current DeFi space.
Solution:
Using DCA to buy the same amount of ETH/WETH every month for a set period of time through Uniswap with DAI.

This project will be a DCA(Dollar Cost Average, https://en.wikipedia.org/wiki/Dollar_cost_averaging ) smart contract to purchase WETH with DAI, with the same chosen amount every month until specified end date.

DAI -> WETH

User flow:

1. User choose a Wallet where the DAI will be taken from and used to pull WETH with
2. User specify end date
3. User specify amount to be purchased on each conversion once a month.
4. smart contract calculate the total amount of DAI to be taken, based on end date and specified amount for each conversion.
5. User approve total amount of DAI to be withdrawn by smart contract
6. User transfers the total amount to smart contract from wallet
7. There will be a list of Users, for each user there will be monthly purchase amount, deposited DAI, wallet address and end date.
8. If monthly purchase amount > 0 && deposited DAI >= monthly purchase amount, the monthly purchase amount gets added together with the rest of monthly purchases from other users amounts to a single sum for all DAI to be converted to WETH this month.
9. WETH gets into the smart contract with an array with objects which each include an amount and address the amount belongs to.
10. Users can then call the smart contract and pull their WETH as well as cancel to pull their remaining DAI .

Alternative flow (pulling approved DAI from user wallets instead of having users send them):
User flow:

1. User choose a Wallet where the DAI will be taken from and used to pull WETH with
2. User specify end date
3. User specify amount to be purchased on each conversion once a month.
4. smart contract calculate the total amount of DAI to be taken, based on end date and specified amount for each conversion.
5. User approve total amount of DAI to be withdrawn by smart contract
6. For each user, there will be a list of monthly purchase amounts, wallets and end date.
7. If purchase amount > 0, allowed spending is >= purchase amount, and DAI in wallet > allowed spending, the purchase amount gets added together with the rest of monthly purchase amounts to a single sum for all DAI to be converted to WETH this month.
8. WETH gets into the smart contract with an array with objects which each include an amount and address the amount belongs to.
9. Users can then call the smart contract and pull their WETH .

First version, basic MVP with a smart contract that only supports 1 user.

1. Smart contract will be deployed manually, the parameters needed will be collected from a simple contact form.
2. User will be notified via email manually when the smart contract is available.
3. User will be able to specify the address deployed smart contract into a frontend in order to see: How much WETH has been purchased and have the option to PULL the WETH out of it.


Update! :
All users DAI will be pooled together, a big reason for using this smart contract will be to be able to buy tiny amounts frequently without
having GAS costs ruin you.


Some more logic:

Example: 1ETH = 1DAI

alice deposits 60
bob deposits 40

smart contract runs and buy for 10
smart contract updates calimableWeth balances by checking the depositedDAI

alice claimable WETH becomes 6, bobs 4


alice withdraw her 6 WETH.
Essentially, making her dai balance 6 DAI less. to 54 
her claimable WETH goes down to 0 while bob still have 4 claimable WETH left.


now alice have deposited 54
and bob have deposited 40, 

the DAI balance to buy with is now 90.


contract keeps buying dai until there is no left,

WETH goes down in value to half so 1 DAI = 2 WETH

bob want to withdraw,
the weth available is 180 + 4, 184

4 belongs to bob and 40/94 * 184 also belongs to bob: 78.2978723404 also belongs to bob. 
in total bob gets 82.2978723404 WETH. 



