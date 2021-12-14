const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  describe("YourContract", function () {
    it("Should deploy YourContract", async function () {
      const YourContract = await ethers.getContractFactory("DcaTogether");

      myContract = await YourContract.deploy(
        "0xe592427a0aece92de3edee1f18e0157c05861564"
      );
    });
    describe("depositTokens()", function () {
      it("Should be able to deposit", async function () {
        const [owner, addr1] = await ethers.getSigners();
        const amountToDeposit = ethers.utils.parseEther("200");
        const amountToExchange = ethers.utils.parseEther("20");
        await myContract.depositTokens(amountToDeposit, amountToExchange);

        //todo replace totalDai with the user thats calling balance
        expect(await myContract.totalDai()).to.equal(amountToDeposit);
        // await myContract.balances(addr1);

        // expect(await myContract.balances(addr1)).to.equal(amountToDeposit);
      });
    });
    // describe("withdraw()", function () {
    //   it("Should be able to withdraw", async function () {
    //     const amountToDeposit = ethers.utils.parseEther("200");
    //     const amountToExchange = ethers.utils.parseEther("20");
    //     await myContract.depositTokens(amountToDeposit, amountToExchange);
    //     // expect(await myContract.totalDai.to.equal(amountToDeposit));
    //     expect(await myContract.totalDai()).to.equal(amountToDeposit);
    //   });
    // });
    // describe("setAmountToExchange()", function () {
    //   it("Should be able to set a new exchange amount", async function () {
    //     const newAmount = 200;

    //     await myContract.setAmountToExchange(newAmount);
    //     expect(
    //       await myContract.setAmountToExchange(newAmount)
    //     ).to.be.revertedWith(
    //       "your exchange amount needs to be bigger than your balance, deposit more DAI!"
    //     );
    //   });
    // });

    // describe("setAmountToExchange()", function () {
    //   it("Should be able to set a new exchange amount", async function () {
    //     const newAmount = 200;
    //     await myContract.setAmountToExchange(newAmount);
    //     await myContract.setAmountToExchange(newAmount);
    //     expect(await myContract.userAmountToExchange(msg.sender)).to.equal(
    //       newAmount
    //     );
    //   });
    // });
  });
});
