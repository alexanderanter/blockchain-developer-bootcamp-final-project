pragma solidity >=0.6.7;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
// import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract YourContract is Ownable {

  using SafeMath for uint256;
 
    //specify owner, maybe not necessary?
  // address public myOwner = 0x0c9A1E4a543618706D31F33b643aba10E0D9048e;
  uint256 public deadline = block.timestamp + 30 seconds;

  //declare variable to decide if Exchange is available or not
  bool public openForExchange;

  //declare array to store user addresses and be able to iterate through users
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


  function percent(uint numerator, uint denominator, uint precision) public returns(uint quotient) {

         // caution, check safe-to-multiply here
        uint _numerator  = numerator * 10 ** (precision+1);
        // with rounding of last digit
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return ( _quotient);
  }


  function transfer(address to, uint256 amount) public {
    require( balances[msg.sender] >= amount, "NOT ENOUGH");
    balances[msg.sender] -= amount;
    balances[to] += amount;
  }

  function withdraw() public onlyOwner {

      (bool success, ) = msg.sender.call{value: address(this).balance}("");
      require( success, "FAILED");
      
      totalWeth = totalWeth - address(this).balance;
    

        //if transfer success
      uint usedDaii = usedDai[msg.sender];
      uint newDaiBalance = balances[msg.sender] - usedDaii;

      usedDai[msg.sender] = 0;
      //remove the DAI that alice already used up when withdrawing
      balances[msg.sender] = newDaiBalance;
      // reset the wethclaimable to 0 as Alice withdrawn all
      wethClaimable[msg.sender] = 0;

          
      emit Withdraw(msg.sender, balances[msg.sender]);
    
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
      totalDai += msg.value;


      //todo remove test!
     // exchange(5);

      
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
      console.log(addressIndexes[i], "updating" );
        updateClaim(addressIndexes[i]);
     }

  }



function updateClaim(address user) public returns(uint) {

  console.log(user, "user");

  uint daiBalance = balances[user];

  console.log(daiBalance, "daibalance ");
  console.log(totalDai, "totalDai");
  console.log(totalConvertedDai, "totalConvertedDai");
  
  
  // uint spentDai = (daiBalance / totalDai) * totalConvertedDai;

  uint spentDai = percent(daiBalance,totalDai,3) * totalConvertedDai;

  console.log(spentDai, "spentDai ");
  usedDai[user] += spentDai;


  // uint claimableWeth = (spentDai / totalConvertedDai) * totalWeth;

  uint percentageOfPool = percent(spentDai,totalConvertedDai,3);
  console.log(percentageOfPool, "percent");
  uint claimableWeth =  percentageOfPool * totalWeth * 10000000000000;

  console.log(claimableWeth, "claimableWeth1");

  claimableWeth = claimableWeth / 10000000000000000000;
  console.log(claimableWeth, "claimableWeth");
  wethClaimable[user] = claimableWeth;
  return claimableWeth;
} 



  //todo write a new sprivate function that can be trigged from either owner or public that makes the exchange
  



}
