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

  constructor(address tokenAddress, ISwapRouter _swapRouter ) public {
    yourToken = YourToken(tokenAddress);
    swapRouter = _swapRouter;
    //transfer in deploy script instead
    // transferOwnership(0x0c9A1E4a543618706D31F33b643aba10E0D9048e);

    // balances[myOwner] = 1000000000000000000;
  }

 
    //specify owner, maybe not necessary?
  // address public myOwner = 0x0c9A1E4a543618706D31F33b643aba10E0D9048e;
  uint256 public deadline = block.timestamp + 50 seconds;

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
      // msg.sender must approve this contract

      // Transfer the specified amount of DAI to this contract.
      // TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountIn);

      // Approve the router to spend DAI.
      TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

      // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
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

  /// @notice swapExactOutputSingle swaps a minimum possible amount of DAI for a fixed amount of WETH.
  /// @dev The calling address must approve this contract to spend its DAI for this function to succeed. As the amount of input DAI is variable,
  /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
  /// @param amountOut The exact amount of WETH9 to receive from the swap.
  /// @param amountInMaximum The amount of DAI we are willing to spend to receive the specified amount of WETH9.
  /// @return amountIn The amount of DAI actually spent in the swap.
  function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) public returns (uint256 amountIn) {
      // Transfer the specified amount of DAI to this contract.
      TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amountInMaximum);

      // Approve the router to spend the specifed `amountInMaximum` of DAI.
      // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
      TransferHelper.safeApprove(DAI, address(swapRouter), amountInMaximum);

      ISwapRouter.ExactOutputSingleParams memory params =
          ISwapRouter.ExactOutputSingleParams({
              tokenIn: DAI,
              tokenOut: WETH9,
              fee: poolFee,
              recipient: msg.sender,
              deadline: block.timestamp,
              amountOut: amountOut,
              amountInMaximum: amountInMaximum,
              sqrtPriceLimitX96: 0
          });

      // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
      amountIn = swapRouter.exactOutputSingle(params);

      // For exact output swaps, the amountInMaximum may not have all been spent.
      // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
      if (amountIn < amountInMaximum) {
          TransferHelper.safeApprove(DAI, address(swapRouter), 0);
          TransferHelper.safeTransfer(DAI, msg.sender, amountInMaximum - amountIn);
      }
  }









  function transfer(address to, uint256 amount) public {
    require( balances[msg.sender] >= amount, "NOT ENOUGH");
    balances[msg.sender] -= amount;
    balances[to] += amount;
  }

  function withdraw() public {
      console.log(wethClaimable[msg.sender], "CHEEECK IT");


      //Transfer ETH from Smart Contract to user
      (bool success, ) = msg.sender.call{value: wethClaimable[msg.sender]}("");
      require( success, "NOT ENOUGH ETH IN SMART CONTRACT, TRY AGAIN LATER");

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
  function withdrawAll() public onlyOwner {

    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require( success, "FAILED");

    emit Withdraw(msg.sender, balances[msg.sender]);
  
}



    function depositTokens(uint256 amount) public returns (uint) {

      require(amount > 10000000000000000000, "Specify the amount you want to deposit minimum 10 DAI");

      balances[msg.sender] += amount;
      //add user if they don't exist
      if (existingUser[msg.sender] == false){
        existingUser[msg.sender] = true;
        addressIndexes.push(msg.sender);

        //set default exchange amount to 10
        //todo increase default before production to around 500 USD
        userAmountToExchange[msg.sender] = 10000000000000000000;
        totalAmountToExchange = totalAmountToExchange + 10000000000000000000;
      }

      //Make it possible to exchange
      openForExchange = true;
      totalDai += amount;



      // require(yourToken.balanceOf(msg.sender) >= amount, "You do not have enough tokens to sell");





      //replaced with dai
      // require(
      //     yourToken.allowance(msg.sender, address(this)) >= amount,
      //     "Token allowance too low"
      // );
     
      // _safeTransferFrom(yourToken, msg.sender, address(this), amount);

      TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), amount);



      emit DepositTokens(msg.sender, amount);
      return balances[msg.sender];
  }

    function timeLeft() public view returns(uint256) {
      // check the timeleft which is used to allow anyone to exchange all funds at once in case something happens to owner
      return block.timestamp > deadline ? 0 : deadline - block.timestamp;
    }



    // backup function in case Owner would die or never exchange deposited funds.
  function exchangeAll() public {
      require(timeLeft() == 0, "not enough time");
      //make sure that something has been staked so its open for exchange
      require(openForExchange == true, "not open for exchange" );
      convert(address(this).balance);

  }
  //Owner can trig this whenever,
  function exchange() public onlyOwner {
    require(totalAmountToExchange >= 0, "not enough to convert");
    require(totalAmountToExchange <= totalDai, "not enough ETH staked");
    //todo add functionality for uniswap trade
    convert(totalAmountToExchange);
  }

  function convert(uint amount) private {

    //dummy conversion
    // uint wethToAdd = amount / 5;


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
  }



function updateClaim(address user) public returns(uint) {

  console.log(user, "user");

  uint daiBalance = balances[user];

  console.log(daiBalance, "daibalance ");
  console.log(totalDai, "totalDai");
  console.log(totalConvertedDai, "totalConvertedDai");
  
  


  uint spentDai = percent(daiBalance,totalDai,3) * totalConvertedDai;

  console.log(spentDai, "spentDai ");
  usedDai[user] += spentDai / 1000;

  uint percentageOfPool = percent(spentDai,totalConvertedDai,3);
  console.log(percentageOfPool, "percent");
  uint claimableWeth =  percentageOfPool * totalWeth * 10000000000000;
  console.log(claimableWeth, "claimableWeth1");
  claimableWeth = claimableWeth / 10000000000000000000;
  console.log(claimableWeth, "claimableWeth");
  wethClaimable[user] = claimableWeth;
  return claimableWeth;
} 



function setAmountToExchange(uint256 amount) public {
    uint256 previousAmount = userAmountToExchange[msg.sender];
    userAmountToExchange[msg.sender] = amount;

    totalAmountToExchange = totalAmountToExchange - previousAmount + amount;
}


  // event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);





  // function buyTokens() public payable {
  //   uint tokensPurchased = msg.value * tokensPerEth;
  //   yourToken.transfer(msg.sender, tokensPurchased);

  //   emit BuyTokens(msg.sender, msg.value, tokensPurchased);

  // }



  function _safeTransferFrom(
      IERC20 token,
      address sender,
      address recipient,
      uint amount
  ) private {
      bool sent = token.transferFrom(sender, recipient, amount);
      require(sent, "Token transfer failed");
  }

  function deposit() public payable {}



}
