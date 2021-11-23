pragma solidity =0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract Vendor is Ownable {
  using SafeMath for uint256;

  YourToken yourToken;

  uint256 public constant tokensPerEth = 100;
    //rinkeby DAI
  //todo replace for mainnet DAI before production
  address public constant DAI = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;

  //rinkebyWETH
  //todo replace for mainnet WETH before production
  address public constant WETH9 = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

// UNISWAP
// Todo inherit the swap router instead of passing it in, passing it in below for simplicity

ISwapRouter public immutable swapRouter;

 // we will set the pool fee to 0.3% on UNISWAP
uint24 public constant poolFee = 3000;
uint256 public deadline;
  constructor(address tokenAddress, ISwapRouter _swapRouter ) public {
    yourToken = YourToken(tokenAddress);
    swapRouter = _swapRouter;
    deadline = block.timestamp + 120 seconds;
    //increase deadline a lot

    //transfer in deploy script instead
    // transferOwnership(0x0c9A1E4a543618706D31F33b643aba10E0D9048e);

  }


  //declare variable to decide if Exchange is available or not
  bool public openForExchange;

  //declare array to store user addresses and be able to iterate through users
  address[] public addressIndexes;

  //refactor to a structuser instead with only 1 mapping https://github.com/bernardpeh/solidity-loop-addresses-demo/blob/master/loop-demo.sol https://bitbucket.org/rhitchens2/soliditycrud/src/master/
  mapping(address => uint256) public balances;
  mapping(address => uint256) public wethClaimable;
  mapping(address => uint256) public usedDai;
  mapping(address => bool) public existingUser;

  //keep track of what each user want to exchange every conversion
  mapping(address => uint256) public userAmountToExchange;

  event DepositTokens(address depositor, uint256 amountOfTokens);

  event Withdraw(address accountAddress, uint256 amount);

  //Total deposited funds available for conversion
  uint256 public totalDai;
  //Total funds thats been converted
  uint256 public totalConvertedDai;
  //Total funds thats available for withdrawal
  uint256 public totalWeth;

  //Total DAI that should be converted every exchange
  uint256 public totalAmountToExchange;
 


  function percent(uint numerator, uint denominator, uint precision) public returns(uint quotient) {

         // caution, check safe-to-multiply here
        uint _numerator  = numerator * 10 ** (precision+1);
        // with rounding of last digit
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return ( _quotient);
  }


  //UNSIWAP ROUTER below:
     /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    
    function swapExactInputSingle(uint256 amountIn) public returns (uint256 amountOut) {

      // Approve the router to spend DAI.
      TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

      // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
      // todo fix amountOutMinimum
      // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
      ISwapRouter.ExactInputSingleParams memory params =
          ISwapRouter.ExactInputSingleParams({
              tokenIn: DAI,
              tokenOut: WETH9,
              fee: poolFee,
              recipient: address(this),
              deadline: block.timestamp,
              amountIn: amountIn,
              amountOutMinimum: 0,
              sqrtPriceLimitX96: 0
          });

      // The call to `exactInputSingle` executes the swap.
      amountOut = swapRouter.exactInputSingle(params);
  }

  function transfer(address to, uint256 amount) public {
    require( balances[msg.sender] >= amount, "NOT ENOUGH");
    balances[msg.sender] -= amount;
    balances[to] += amount;
  }

  function withdraw() public {
      console.log(wethClaimable[msg.sender], "CHEEECK IT");

      require(wethClaimable[msg.sender] > 0, "NOTHING TO WITHDRAW");


      //todo check if we can make a bool success from the transferhelper! something like below
      // (bool success, ) = msg.sender.call{value: wethClaimable[msg.sender]}("");
      // require( success, "NOT ENOUGH ETH IN SMART CONTRACT, TRY AGAIN LATER");


      TransferHelper.safeTransferFrom(WETH9, address(this), msg.sender, wethClaimable[msg.sender]);


      emit Withdraw(msg.sender, wethClaimable[msg.sender]);

      //if transfer success
      totalWeth = totalWeth - wethClaimable[msg.sender];
  
      uint usedDaii = usedDai[msg.sender];
      uint newDaiBalance = balances[msg.sender] - usedDaii;

      usedDai[msg.sender] = 0;
      //remove the DAI that alice already used up when withdrawing
      balances[msg.sender] = newDaiBalance;
      // reset the wethclaimable to 0 as Alice withdrawn all
      wethClaimable[msg.sender] = 0;

          
    
  }

//emergencyfunction that lets the owner of smartcontract to withdraw all the ETH at once
//todo change for WETH
  function withdrawAll() public onlyOwner {

    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require( success, "FAILED");

    emit Withdraw(msg.sender, balances[msg.sender]);
  
}



    function depositTokens(uint256 amount, uint256 amountToExchange) public returns (uint) {

      require(amount >= 10000000000000000000, "Specify the amount you want to deposit minimum 10 DAI");

      balances[msg.sender] += amount;
      //add user if they don't exist
      if (existingUser[msg.sender] == false){
        require(amount > amountToExchange, "Your exchange amount must be larger than your deposit!");
        existingUser[msg.sender] = true;
        addressIndexes.push(msg.sender);

        //set default exchange amount to 10
        //todo increase default before production to around 500 USD
        require(amountToExchange > 0, "FIRST DEPOSIT NEED AN EXCHANGE AMOUNT");
        userAmountToExchange[msg.sender] = amountToExchange;
        totalAmountToExchange = totalAmountToExchange + amountToExchange;
      }

      //Make it possible to exchange
      openForExchange = true;
      totalDai += amount;


//todo fix this require 
      // require(yourToken.balanceOf(msg.sender) >= amount, "You do not have enough tokens to sell");

      TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amount);



      emit DepositTokens(msg.sender, amount);
      return balances[msg.sender];
  }

    function timeLeft() public view returns(uint256) {
      // check the timeleft which is used to allow anyone to exchange all funds at once in case something happens to owner
      return block.timestamp > deadline ? 0 : deadline - block.timestamp;
    }



    // Exchange function open for anyone to trigger after the deadline is over! Deadline updates each conversion
  function exchangeAll() public {
      require(timeLeft() == 0, "not enough time");
      //make sure that something has been staked so its open for exchange
      require(openForExchange == true, "not open for exchange" );
      require(totalAmountToExchange >= 0, "not enough to convert");
      require(totalAmountToExchange <= totalDai, "not enough ETH staked");
      convert(totalAmountToExchange);

  }
  //Owner can trig this whenever,
  function exchange() public onlyOwner {
    require(totalAmountToExchange >= 0, "not enough to convert");
    require(totalAmountToExchange <= totalDai, "not enough ETH staked");
    //todo add functionality for uniswap trade
    convert(totalAmountToExchange);
  }

  function convert(uint amount) private {

    uint wethToAdd = swapExactInputSingle(amount);
    //require( success, "FAILED");
    
    totalConvertedDai += amount;
    totalWeth += wethToAdd;


    //loop through and update all users claimable eth
    for (uint i=0; i < addressIndexes.length; i++) {
      console.log(addressIndexes[i], "updating" );
        updateClaim(addressIndexes[i]);
     }

     //remove the converted DAI from the total available
     totalDai -= amount;
     //extend deadline with 2 minutes after an exchange
     deadline = block.timestamp + 120 seconds;
  }

//todo fixed so that when a user have no more dai to exchange they don't credit for exchange
//todo  make sure multiple deposits work well
  //claim based on exchangeamount
  function updateClaim(address user) public returns(uint) {

    uint daiToChange = userAmountToExchange[user];
    
//percentage of the exchange pool multiplied with the total converted dai to see what the user spent
    uint spentDai = percent(daiToChange,totalAmountToExchange,3) * totalConvertedDai;
    usedDai[user] += spentDai / 1000;
    //calculate the spentdai % in comparison with the total converted dai
    uint percentageOfPool = percent(spentDai,totalConvertedDai,3);
    uint claimableWeth =  percentageOfPool * totalWeth * 10000000000000;
    claimableWeth = claimableWeth / 10000000000000000000;
  
  
  
    wethClaimable[user] = claimableWeth;

    balances[user] -= daiToChange;
    //check if the new user balance is enough to amount to exchange, otherwise change exchange balance
    if(balances[user] < userAmountToExchange[user]){
      uint256 previousAmount = userAmountToExchange[user];
      userAmountToExchange[user] = balances[user];
      totalAmountToExchange = totalAmountToExchange - previousAmount + userAmountToExchange[user];
    }
    return claimableWeth;
 } 
  
 //claim based on deposit
// function updateClaim(address user) public returns(uint) {



//   uint daiBalance = balances[user];
//   uint spentDai = percent(daiBalance,totalDai,3) * totalConvertedDai;
//   usedDai[user] += spentDai / 1000;
//   uint percentageOfPool = percent(spentDai,totalConvertedDai,3);
//   uint claimableWeth =  percentageOfPool * totalWeth * 10000000000000;
//   claimableWeth = claimableWeth / 10000000000000000000;



//   wethClaimable[user] = claimableWeth;
//   return claimableWeth;
// } 



function setAmountToExchange(uint256 amount) public {
    require(balances[msg.sender] > amount, "your exchange amount needs to be bigger than your balance, deposit more DAI!");
    uint256 previousAmount = userAmountToExchange[msg.sender];
    userAmountToExchange[msg.sender] = amount;

    totalAmountToExchange = totalAmountToExchange - previousAmount + amount;
}

  function _safeTransferFrom(
      IERC20 token,
      address sender,
      address recipient,
      uint amount
  ) private {
      bool sent = token.transferFrom(sender, recipient, amount);
      require(sent, "Token transfer failed");
  }

}

//todo

// FIX overflow issue with amount of weth to withdraw
// FIX bug with infura ID, figure out how to load in the .env properly for react-app
// 2. Write tests
// 3. Review for security issues
// 4. Write guidelines 


// todo in the future:
// consider switching out the infura id with the full link from .env to constants.js
// Add a "panic sell" btn that converts all the collected WETH to DAI to start over the DCA, valid strategy when ETH reaches new ATH
// Make sure there is no conversion if its not enough liquidity in uniswap
// Switch out wETH for rETH after researching liqudity on rETH *mainnet rETH: 0xae78736Cd615f374D3085123A210448E74Fc6393