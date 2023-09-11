// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomatedFundsTransfer {
    address public recipient;
    uint256 public startTime;
    // uint256 public endTime;
    uint256 public withdrawTime;
    bool public fundsTransferred;

    constructor(address _recipient) {
        require(_recipient != address(0), "Invalid recipient address");
        recipient = _recipient;
        // startTime = block.timestamp;
        // endTime = startTime + 7 days;
        // withdrawTime = endTime + 3 days;
        fundsTransferred = false;
    }

    receive() external payable {
        // require(block.timestamp < endTime, "Funding period has ended");
        startTime = block.timestamp;
        withdrawTime = startTime + 3 days;
    }

    function transferFunds() external {
        //if require condition is FALSE, the statement will return ""Funding period has not ended yet", without executing the next lines..
        // require(block.timestamp >= endTime, "Funding period has not ended yet");
        require(block.timestamp >= withdrawTime,  "Waiting PERIOD for Fund Transfer is not over");
        require(!fundsTransferred, "Funds already transferred");

        // Transfer all contract balance to the specified recipient
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(success, "Transfer failed");

        fundsTransferred = true;
    }
}