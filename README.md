# 🏗 DCAtogether

# blockchain-developer-bootcamp-final-project

buyTogether:

The Problem: Crypto is volatile, GAS fees are high, Centralized exchanges is similar to a bank and the reason crypto exists in the first place is to get rith of centralized control over your money, something exchanges does not.
Solution: An affordable way to buy up crypto with small amounts on a regular(semi-regular) basis.

Buying small amounts of crypto on a regular basis costs too much in gas fees its not worth it,
by pooling together a others so the small purchases becomes big ones, users can save a lot on gas fees and also, instead of 100 people remembering to
make 100 transactions every month, 1 user can do it for all 100.

# 🏄‍♂️ Quick Start

Option 1:
use deployed version at http://planty-ray.surge.sh/

1. Login to metamask and make sure you are on RINKEBY and have some RINKEBY ETH.

2. Get some test DAI:
   option 1A:
   Go to https://app.uniswap.org/#/swap, click on select a token, paste in:
   0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa (Rinkeby test DAI), then swap your rinkeby ETH for some Rinkeby DAI.
   option 1B:
   go to https://app.compound.finance/ , connect your wallet, click on DAI under Supply Markets, then choose the "Withdraw" tab, then at the bottom of the popup,
   click on "Faucet" and accept the transaction from metamask.

3. Go to http://planty-ray.surge.sh/ connect metamask wallet on Rinkeby that have some Rinkeby ETH and Rinkeby DAI
4. Use the dapp to make a big deposit of DAI and then let it be converted with other users on a regular basis to WETH that can be withdrawn.

Option 2:

Run locally but with contracts on rinkeby

> copy sample.env in react-app and rename copy .env, and add your own infura credentials for rinkeby.

copy example.env in hardhat and rename the copy .env and add your own infura credentials for rinkeby.

create a new metamask account, save the seed,
create a mnemonic.txt file in hardhat folder , copy in the seed of your account with rinkeby, fill the new account with rinkeby eth.

```bash
yarn install
```

> in a second terminal window, start your 📱 frontend:

```bash
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
yarn deploy
```

to test:

```bash
yarn test
```

Option 3: Run on local chain

Prerequisites: [Node](https://nodejs.org/en/download/) plus [Yarn](https://classic.yarnpkg.com/en/docs/install/) and [Git](https://git-scm.com/downloads)

> install and start your 👷‍ Hardhat chain:

```bash
yarn install
yarn chain
```

> change to work with localhost instead of rinkeby //need more details here
> in a second terminal window, start your 📱 frontend:

```bash
yarn start
```

> in a third terminal window, 🛰 deploy your contract:

```bash
yarn deploy
```

🔏 smart contract in `packages/hardhat/contracts`

📝 frontend `App.jsx` in `packages/react-app/src`

💼 deployment scripts in `packages/hardhat/deploy`

📱 Open http://localhost:3000 to see the app

# 📚 NOT WORKING? Check scaffold eth docs:

visit: [docs.scaffoldeth.io](https://docs.scaffoldeth.io)

# use case

1. Alice deposit DAI to their connected wallet through metamask
2. Smart contract updates the total dai deposited and makes note of how much Alice deposited
3. Owner triggers a function that converts a small amount deposited DAI to WETH that only owner can trigger.
4. Alice decides to withdraw ALL the current WETH she got right to,
5. totalDAI deposited updates as well as the DAIdeposited Alice have put in
6. claimable WETH for Alice goes to 0
7. Owner triggers a function that converts a small amount deposited DAI to WETH that only owner can trigger.
8. Alice claimable WETH goes up again but this time the % of the total weth bought is less because she already cashed out once and smaller % of the pool!

# Future:

implement a check so the owner cant do too many frequent conversion
add all users to the owner multisig so any user can trigger a conversion (if its not too soon!)

Create a incentivised mechanism for users to manage and trigger the conversion on a regular basis

To protect if the owner dies:
Implement a fail-safe so if the Owner have not converted for serious long time (store blocktime of each conversion and compare it with current when trigger), any user can trigger a convertALLDAI function so all users can convert. Or simply create a votefunction so if enough users vote to convertALL, it converts!
Can also be useful if ETH crashes in value and all users want to buy for everything at once.

Implement chainlink oracle to do this on a regular basis instead of relying on a owner that does this.
