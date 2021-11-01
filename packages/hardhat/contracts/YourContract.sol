pragma solidity >=0.6.7;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourContract is Ownable {

    //specify owner, maybe not necessary?
  // address public myOwner = 0x0c9A1E4a543618706D31F33b643aba10E0D9048e;
  uint256 public deadline = block.timestamp + 30 seconds;

  //declare variable to decide if Exchange is available or not
  bool public openForExchange;

  address[] public addressIndexes;

  //refactor to a structuser instead with only 1 mapping https://github.com/bernardpeh/solidity-loop-addresses-demo/blob/master/loop-demo.sol https://bitbucket.org/rhitchens2/soliditycrud/src/master/
  mapping(address => uint256) public balances;
  mapping(address => uint256) public wethClaimable;
  mapping(address => uint256) public usedDai;
  mapping(address => bool) public existingUser;


  event Stake(address accountAddress, uint256 amount);
  event Withdraw(address accountAddress, uint256 amount);

  uint256 public totalDai;
  uint256 public totalConvertedDai;
  uint256 public totalWeth;
  uint256 public amountToConvert;

  constructor() {
    //set the owner to a different address than the deploy wallet
   transferOwnership(0x0c9A1E4a543618706D31F33b643aba10E0D9048e);
    // Set owner balance to 1000 just to test
  //  balances[myOwner] = 1000000000000000000;

//redundant
  // openForExchange = false;
  }



  // function transfer(address to, uint256 amount) public {
  //   require( balances[msg.sender] >= amount, "NOT ENOUGH");
  //   balances[msg.sender] -= amount;
  //   balances[to] += amount;
  // }

  function withdraw() public onlyOwner {
      (bool success, ) = msg.sender.call{value: address(this).balance}("");
      require( success, "FAILED");
      openForExchange = false;
      emit Withdraw(msg.sender, balances[msg.sender]);
      balances[msg.sender] = 1;
    
  }

  function stake() public payable returns (uint) {
      balances[msg.sender] += msg.value;

      //add user if they don't exist
      if (existingUser[msg.sender] == false){
        existingUser[msg.sender] = true;
        addressIndexes.push(msg.sender);
      }
  


      emit Stake(msg.sender, msg.value);
      openForExchange = true;



      //todo remove test!
      exchange(5);

      
      return balances[msg.sender];
    }

    function timeLeft() public view returns(uint256) {
      // check if now got a bigger timestamp than the deadline, if yes then 0 timeleft,if not return the remaining time.
      return block.timestamp > deadline ? 0 : deadline - block.timestamp;
    }


  function exchangeTrigger() public {
      require(block.timestamp >= deadline, "not enough time");
      require(openForExchange == true, "not open for exchange" );

  }

  function exchange(uint amount) public onlyOwner {
    
    uint wethToAdd = amount / 5;
    //require( success, "FAILED");
    
    totalConvertedDai += amount;
    totalWeth += wethToAdd;


    //loop through and update all users claimable eth
    for (uint i=0; i < addressIndexes.length; i++) {
        updateClaim(addressIndexes[i]);
     }

  }


  function updateClaim(address user) public {

    console.log(user, "user");
  } 

  //todo write a new private function that can be trigged from either owner or public that makes the exchange
  


    // string public purpose = "Building Unstoppable Appps!!x";
  // event SetPurpose(address sender, string purpose);
  // function setPurpose(string memory newPurpose) public payable {

  
  //     purpose = newPurpose;
  //     console.log(msg.sender,"set purpose to",purpose);
  //     emit SetPurpose(msg.sender, purpose);
  // }


}
