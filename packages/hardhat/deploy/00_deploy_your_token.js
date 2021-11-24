// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  //send in the uniswap router as argument
  await deploy("DcaTogether", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: ["0xe592427a0aece92de3edee1f18e0157c05861564"],
    log: true,
  });

  // Getting a previously deployed contract
  const dcaTogetherContract = await ethers.getContract("DcaTogether", deployer);
  await dcaTogetherContract.transferOwnership(
    "0xBC42f234b6173A288D91fA0342fF0270Ba376792"
  );
};
module.exports.tags = ["DcaTogether"];
