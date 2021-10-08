pragma solidity >=0.4.22 <0.6.0;

contract DCA {
     //set the owner of the contract *will be a Gnosis multisig*
    address public owner = msg.sender;
    uint public totalDai;
    uint public totalConvertedDai;
    uint public totalWeth;

    // Mapping from address to uint used to store the DAI balances of the users.
    mapping (address => uint) internal currentDaiBalance;

    //keep track of how much every user have the right to claim, updates after each purchase
    mapping (address => uint) internal wethClaimable;

    //keep track of how much every user have bought WETH with.
    mapping (address => uint) internal usedDai;

    //Event that shows that a deposit have been made
    event Deposit(uint amount);

    //event that shows how much thats been converted from dai to weth
    event Converted(uint amount);
    
    //Event that shows how much you have right to withdraw
    event WethToWithdraw(uint amount);

   //Converts DAI to WETH via Uniswap, can only be called via the multisig
   function convertDaiToWeth onlyOwner{
       // logic to convert the DAI in the smart contract to WETH
       //need an await function here to trigger after the conversion via uniswap has been done
       uint amount += totConvertedDai;
       totalWeth += convertedWeth;
       emit Converted(amount);

        //keep track of how much dai each user have spent
        usedDai = depositedDai[address] / totalDAI * convertedDai;
        //keep track of how much dai each user have spent in total
        usedDai[address] += usedDai;
        // update wethClaimable
        wethClaimable[address] = usedDai / convertedDai * totalWeth;

   }


    function withdraw(){
        uint amountToWithdraw = calculateRightToWithdraw(msg.sender);

        //should be replaced with require or similar 
        if(amountToWithdraw > 0) {
            //withdraw logic of ALL the erc20 (WETH) here

            //todo: successCheck here
            //if success:
            wethClaimable[msg.sender] = 0;
            totalDai - currentDaiBalance[msg.sender] ;
            currentDaiBalance[msg.sender] = 0;

        }
    }
   // checks the users WETH they can withdraw
    function calculateRightToWithdraw(address _addr) {
        uint memory amountToWithdraw = currentDaiBalance[_addr] / totalDai * totalWeth;
        emit WethToWithdraw(amountToWithdraw);
    }


   //modifier to check its the owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }


    //todo storage of erc20 in the contract, WETH and DAI.
    //todo  fix the logic so contract keeps track of exactly how much of their DAI has been used 
    //todo  usedDai[address] = depositedDai / totalDAI * convertedDai;
    //todo  fix the mappings, replace with arrays that can be looped through where needed.
    //todo check for security issues
    //todo check for best practices
    //todo fix everything so its real code :D 

}
