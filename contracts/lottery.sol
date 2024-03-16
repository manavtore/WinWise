// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract Lottery {
    address public manager;
    address payable[] public participants;
    bool public execution;
    uint256 public endTime;
    uint256 public lotteryId;

    constructor() {
        manager = msg.sender;
        execution = false;
        lotteryId = 0;
    }

    receive() external payable {
        require(msg.value >= 2 ether, "Insufficient funds sent. Please send more than or equal to two ethers");
        participants.push(payable(msg.sender));
    }
    
    function getParticipantsCount() public view returns(uint) {
        return participants.length;
    }
    function getPool() public view returns(uint256) {
    return address(this).balance;
    }

    function addFunds() external payable {
        require(msg.value > 0, "Sent amount must be greater than zero.");
        participants.push(payable(msg.sender));
    }

    event WinnerDeclared(address winner, uint256 lotteryId);

    function getRandomWinner() private view returns (address payable) {
        bytes32 blockHash = blockhash(block.number - 1); 
        uint256 randomNumber = uint256(blockHash) % participants.length;
        return participants[randomNumber];
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can execute this.");
        _;
    }

    function selectWinner() public onlyManager {
        require(!execution, "Winner has already been selected.");
        require(participants.length > 0, "No participants in the lottery.");

        endTime = block.timestamp + 2 minutes;
        execution = true;
        lotteryId++;
        emit WinnerDeclared(getRandomWinner(), lotteryId);

        uint256 prize = address(this).balance;
        if (participants.length > 1) {
            payable(manager).transfer(prize / 10);
            participants[0].transfer(prize - (prize / 10)); 
        } else {
            participants[0].transfer(prize); 
        }
    }

    function withdrawProfit() public onlyManager {
        require(execution, "Winner has not been selected yet.");
        require(block.timestamp > endTime, "Wait for auto-generation of winner.");

        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Contract balance is zero.");

        payable(manager).transfer(contractBalance);
    }
}
