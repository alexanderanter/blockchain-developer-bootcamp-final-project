pragma solidity =0.7.6;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
    //ToDo: add constructor and mint tokens for deployer,
    //you can use the above import for ERC20.sol. Read the docs ^^^
    // mapping(address => uint256) public balances;
    
    constructor() public ERC20("ALEX", "ALX") {
        _mint(msg.sender, 100000000000000000000000);
    }

}
