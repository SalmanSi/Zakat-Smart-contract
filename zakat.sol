// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Zakat is Ownable, ReentrancyGuard {
    uint256 public eligibilityThreshold; // Threshold in wei for receiving Zakat
    uint256 public maxClaimAmount; // Maximum amount that can be claimed at once

    mapping(address => uint256) public zakatContributions; // Tracks Zakat paid by each address
    mapping(address => bool) public eligibleRecipients; // Tracks eligible Zakat recipients
    mapping(address => uint256) public balances; 

    event ZakatPaid(address indexed payer, uint256 amount);
    event ZakatClaimed(address indexed recipient, uint256 amount);

    // Constructor initializing the contract with Zakat parameters and owner address
    constructor( uint256 _eligibilityThreshold, uint256 _maxClaimAmount,address initialOwner) Ownable(initialOwner) {
        eligibilityThreshold = _eligibilityThreshold;
        maxClaimAmount = _maxClaimAmount;
    }

  // Function to pay Zakat
function payZakat() external payable nonReentrant {
    require(msg.value > 0, "Zakat amount must be greater than zero");
    balances[msg.sender] -= msg.value; // Subtract amount from balance
    zakatContributions[msg.sender] += msg.value;
    emit ZakatPaid(msg.sender, msg.value);
}


    // Function to claim Zakat
    function claimZakat(uint256 amount) external nonReentrant {
        require(amount > 0, "Claim amount must be greater than zero");
        require(amount <= maxClaimAmount, "Claim exceeds maximum allowed amount");
        require(address(this).balance >= amount, "Not enough funds in the pool");
        require(balances[msg.sender] <= eligibilityThreshold, "Claimant is not eligible");

        eligibleRecipients[msg.sender] = true;
        balances[msg.sender]+=amount;
        payable(msg.sender).transfer(amount);
        emit ZakatClaimed(msg.sender, amount);
    }

    // Function to check Zakat eligibility
    function isEligibleForZakat(address addr) public view returns (bool) {
        return balances[addr] <= eligibilityThreshold;
    }



    // Function to set eligibility threshold (only owner)
    function setEligibilityThreshold(uint256 newThreshold) external onlyOwner {
        eligibilityThreshold = newThreshold;
    }

    // Function to set maximum claim amount (only owner)
    function setMaxClaimAmount(uint256 newMaxClaim) external onlyOwner {
        maxClaimAmount = newMaxClaim;
    }

    // Function to withdraw funds (only owner)
    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Not enough funds");
        payable(owner()).transfer(amount);
    }
    function getBalance(address account) external view returns (uint256) {
        return account.balance;
    }
    // Fallback function to receive funds
    receive() external payable {
        
    }
}
