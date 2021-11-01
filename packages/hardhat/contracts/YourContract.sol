pragma solidity >=0.6.7;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourContract is Ownable {

    //specify owner, maybe not necessary?
  address public myOwner = 0x0c9A1E4a543618706D31F33b643aba10E0D9048e;

  mapping(address => uint256) public balances;
  event Stake(address accountAddress, uint256 amount);

  
  constructor() {
    //set the owner to a different address than the deploy wallet
   transferOwnership(0x0c9A1E4a543618706D31F33b643aba10E0D9048e);
    // Set owner balance to 1000 just to test
  //  balances[myOwner] = 1000000000000000000;
  }



  function transfer(address to, uint256 amount) public {
    require( balances[msg.sender] >= amount, "NOT ENOUGH");
    balances[msg.sender] -= amount;
    balances[to] += amount;
  }

  function withdraw() public onlyOwner {
      (bool success, ) = msg.sender.call{value: address(this).balance}("");
      require( success, "FAILED");
    
  }

  function stake() public payable returns (uint) {
      balances[msg.sender] += msg.value;
      
      emit Stake(msg.sender, msg.value);

      return balances[msg.sender];
    }



    // string public purpose = "Building Unstoppable Appps!!x";
  // event SetPurpose(address sender, string purpose);
  // function setPurpose(string memory newPurpose) public payable {

  
  //     purpose = newPurpose;
  //     console.log(msg.sender,"set purpose to",purpose);
  //     emit SetPurpose(msg.sender, purpose);
  // }


}
