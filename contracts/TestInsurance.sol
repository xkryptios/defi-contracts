// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract TestInsurance is ConfirmedOwner {
    uint256 public capacity;

    event PolicyCreated(address indexed insuredAddress);
    event ClaimProcessed(address indexed insuredAddress, uint256 coverAmount);

    struct Policy {
        uint256 premium;
        uint256 coverAmount;
        uint256 startDate;
        uint256 endDate;
        bool isClaimed;
    }
    mapping(address => Policy[]) public policies;

    constructor() ConfirmedOwner(msg.sender) {
        capacity = 100 ether;
    }

    function purchaseInsurance(uint256 _coverAmount, uint256 _durationDays) external payable {
        require(_durationDays <= 90, "Duration exceeds maximum of 3 months");
        require(_coverAmount <= capacity, "Cover amount exceeds capacity!");

        // Simplified premium calculation based on coverage amount and risk assessment
        uint256 premium = calculatePremium(_coverAmount,_durationDays);
        require(msg.value == premium, "Incorrect premium amount sent");

        Policy[] storage userPolicies = policies[msg.sender];

        if (userPolicies.length != 0){
            Policy storage latestPolicy = userPolicies[userPolicies.length-1];
            //if policy claimed -> allow,
            require(latestPolicy.isClaimed || latestPolicy.endDate<block.timestamp,"You have already purchased this policy.");
        }

        // all checks cleared
        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + (_durationDays * 1 days);
        capacity = capacity - _coverAmount + premium;

        Policy memory newPolicy;
        newPolicy.premium = premium;
        newPolicy.coverAmount = _coverAmount;
        newPolicy.startDate = startDate;
        newPolicy.endDate = endDate;
        newPolicy.isClaimed = false;

        //creating the new policy
        userPolicies.push(newPolicy);

        emit PolicyCreated(msg.sender);
    }

    function calculatePremium(uint _coverAmount ,uint256 _durationDays) public  pure returns (uint256) {
        // Simplified premium calculation logic
        // based on historical weather data, risk models, etc.
        return _coverAmount; 
    }

    function claim() external payable{
        Policy[] storage userPolicies = policies[msg.sender];
        require(userPolicies.length>0,"You have not purchased this policy");
        Policy storage latestPolicy = userPolicies[userPolicies.length-1];

        require(latestPolicy.startDate <= block.timestamp && block.timestamp <= latestPolicy.endDate, "Policy not active");
        require(!latestPolicy.isClaimed, "Claim already processed");

        latestPolicy.isClaimed = true;
        payable(msg.sender).transfer(latestPolicy.coverAmount);
        emit ClaimProcessed(msg.sender, latestPolicy.coverAmount);
    }
    
    function numPolicies(address userAddress) external view returns(uint256){
        return policies[userAddress].length;
    }

    function withdraw() onlyOwner public payable {
        payable(msg.sender).transfer(address(this).balance);
    }
}