// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;

// import BUSD Token
// imported 
import './BUSDToken.sol';

contract Bank {
    // assign BUSD Token contract to variable
    BUSDToken private bUSDToken;

    // add mappings
    mapping(address => uint) public stakeBalanceOf; // how much player has staked
    mapping(address => uint) public stakeStart; // when player has stake
    mapping(address => bool) public isDeposited; // check if player has staked or withdrawal

    // add events
    event Stake(address indexed user, uint amount, uint timestart);
    event HarvestBUSD(address indexed user, uint amount, uint interest, uint depositeTime);
    
    // add constants
    uint private MIN_AMOUNT = 1e18;   

    // add events
    

    // pass as constructor argument deployed token contract
    constructor(BUSDToken _token) {
        // assign token deployed contract to variable
        bUSDToken = _token;
    }

    // stake on the contract
    function stakeBUSD() payable public {
        address sender = msg.sender;
        //check if msg.sender didn't already deposited funds
        require(!isDeposited[sender], "Error, already staked");
        //check if msg.value is >= than 0.01 ETH
        require(msg.value >= MIN_AMOUNT, "Error, stake amount should be greater/equal to 1 BUSD");
        //increase msg.sender ether deposit balance
        stakeBalanceOf[sender] = stakeBalanceOf[sender] + msg.value;
        //start msg.sender hodling time
        stakeStart[sender] = block.timestamp;
        //set msg.sender deposit status to true
        isDeposited[sender] = true;
        //emit Deposit event
        emit Stake(sender, msg.value, block.timestamp);
    }

    // customer harvest their rewards
    function harvestBUSD() payable public {
        // check if msg.sender deposit status is true
        require(isDeposited[msg.sender], "Error, no previous stake");
        // assing msg.sender BUSD deposit balance to variable for event
        uint userBalance = stakeBalanceOf[msg.sender];
        //check user's hodl time
        uint stakeTime = block.timestamp - stakeStart[msg.sender];
        // total second = 31557600s (365.25 days per year)
        // when user deposite 0.01ETH for a year, our bank wanna send 10% per year for their interest
        // 1ETH = 1e18, 0.01ETH = 1e16, so 10% - 1e15
        // calc interest per second
        // 1e15 / 31557600s = 31688087 wei
        // calc accrued interest
        uint interestPerSecond = 31688087 * (stakeBalanceOf[msg.sender] / 1e16);
        uint interest = stakeTime * interestPerSecond;

        // send reward(BUSD) to user
        bUSDToken.approve(msg.sender, interest);
        require(bUSDToken.transferFrom(msg.sender, address(this), interest), 'Error, cannot receive token');

        // update stakeStart timestamp
        stakeStart[msg.sender] = block.timestamp;

        // emit harvestBUSD
        emit HarvestBUSD(msg.sender, userBalance, interest, stakeTime);       
    }

}


    