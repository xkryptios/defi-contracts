// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
contract EthInsurance3000 is ConfirmedOwner {
    uint public ethPrice;
    uint256 public capacity;
    AggregatorV3Interface internal dataFeed;

    event PolicyPurchased(address indexed insuredAddress);
    event ClaimProcessed(address indexed insuredAddress, uint256 payoutAmount);

    struct Policy {
        uint256 premium;
        uint256 coverAmount;
        uint256 startDate;
        uint256 endDate;
        bool isClaimed;
    }
    mapping(address => Policy[]) public policies;

    constructor() ConfirmedOwner(msg.sender) {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        capacity = 100 ether;
    }

    /**
     * CORE FUNCTIONALITY
     */
    function purchaseInsurance(uint _coverAmount, uint256 _durationDays) external payable {
        require(_durationDays <= 90, "Duration exceeds maximum of 3 months");
        require(_coverAmount <= capacity, "Coverage exceeds capacity!");
        uint256 premium = calculatePremium(_coverAmount,_durationDays);
        require(msg.value == premium, "Incorrect premium amount sent");

        Policy[] storage userPolicies = policies[msg.sender];

        if (userPolicies.length != 0){
            Policy storage latestPolicy = userPolicies[userPolicies.length-1];
            require(latestPolicy.isClaimed || latestPolicy.endDate<block.timestamp,"You have already purchased this policy.");
        }

        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + (_durationDays * 1 days);
        capacity = capacity - _coverAmount + premium;

        Policy memory newPolicy;
        newPolicy.premium = premium;
        newPolicy.coverAmount = _coverAmount;
        newPolicy.startDate = startDate;
        newPolicy.endDate = endDate;
        newPolicy.isClaimed = false;

        userPolicies.push(newPolicy);

        emit PolicyPurchased(msg.sender);
    }
    function calculatePremium(uint _coverAmount, uint256 _durationDays) public pure returns (uint256) {
        // Simplified premium calculation logic, can use more sophisticated algorithms
        // based on the duration, risk models, etc.
        return _coverAmount;
    }
    function claim() external payable  {
        Policy[] storage userPolicies = policies[msg.sender];
        require(userPolicies.length>0,"You have not purchased this policy");
        Policy storage latestPolicy = userPolicies[userPolicies.length-1];

        require(latestPolicy.startDate <= block.timestamp && block.timestamp <= latestPolicy.endDate, "Policy not active");
        require(!latestPolicy.isClaimed, "Claim already processed");

        ethPrice = uint256(getEthPrice());
        require(ethPrice < 3000 * 10**getEthDecimalPlace(), "Ethereum price is not below $3000");

        // Perform claim processing logic...
        latestPolicy.isClaimed = true;
        // Transfer payout
        payable(msg.sender).transfer(latestPolicy.coverAmount);
        emit ClaimProcessed(msg.sender, latestPolicy.coverAmount);
    }
    function numPolicies(address userAddress) external view returns(uint256){
        return policies[userAddress].length;
    }

    /**
     * ORACLE FUNCTIONS
     */
    function getEthPrice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    function getEthDecimalPlace() public view returns(uint){
        return dataFeed.decimals();
    }

    /**
     * UTILITY FUNCTIONS FOR TESTING
     */
    function fundPolicy() external payable {
        capacity += msg.value;
    }
    function withdraw() payable public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
}
contract EthInsurance2000 is ConfirmedOwner {
    uint public ethPrice;
    uint256 public capacity;
    AggregatorV3Interface internal dataFeed;

    event PolicyPurchased(address indexed insuredAddress);
    event ClaimProcessed(address indexed insuredAddress, uint256 payoutAmount);

    struct Policy {
        uint256 premium;
        uint256 coverAmount;
        uint256 startDate;
        uint256 endDate;
        bool isClaimed;
    }
    mapping(address => Policy[]) public policies;

    constructor() ConfirmedOwner(msg.sender) {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        capacity = 100 ether;
    }

    /**
     * CORE FUNCTIONALITY
     */
    function purchaseInsurance(uint _coverAmount, uint256 _durationDays) external payable {
        require(_durationDays <= 90, "Duration exceeds maximum of 3 months");
        require(_coverAmount <= capacity, "Coverage exceeds capacity!");
        uint256 premium = calculatePremium(_coverAmount,_durationDays);
        require(msg.value == premium, "Incorrect premium amount sent");

        Policy[] storage userPolicies = policies[msg.sender];

        if (userPolicies.length != 0){
            Policy storage latestPolicy = userPolicies[userPolicies.length-1];
            require(latestPolicy.isClaimed || latestPolicy.endDate<block.timestamp,"You have already purchased this policy.");
        }

        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + (_durationDays * 1 days);
        capacity = capacity - _coverAmount + premium;

        Policy memory newPolicy;
        newPolicy.premium = premium;
        newPolicy.coverAmount = _coverAmount;
        newPolicy.startDate = startDate;
        newPolicy.endDate = endDate;
        newPolicy.isClaimed = false;

        userPolicies.push(newPolicy);

        emit PolicyPurchased(msg.sender);
    }
    function calculatePremium(uint _coverAmount, uint256 _durationDays) public pure returns (uint256) {
        // Simplified premium calculation logic, can use more sophisticated algorithms
        // based on the duration, risk models, etc.
        return _coverAmount;
    }
    function claim() external payable  {
        Policy[] storage userPolicies = policies[msg.sender];
        require(userPolicies.length>0,"You have not purchased this policy");
        Policy storage latestPolicy = userPolicies[userPolicies.length-1];

        require(latestPolicy.startDate <= block.timestamp && block.timestamp <= latestPolicy.endDate, "Policy not active");
        require(!latestPolicy.isClaimed, "Claim already processed");

        ethPrice = uint256(getEthPrice());
        require(ethPrice < 2000 * 10**getEthDecimalPlace(), "Ethereum price is not below $2000");

        // Perform claim processing logic...
        latestPolicy.isClaimed = true;
        // Transfer payout
        payable(msg.sender).transfer(latestPolicy.coverAmount);
        emit ClaimProcessed(msg.sender, latestPolicy.coverAmount);
    }
    function numPolicies(address userAddress) external view returns(uint256){
        return policies[userAddress].length;
    }

    /**
     * ORACLE FUNCTIONS
     */
    function getEthPrice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    function getEthDecimalPlace() public view returns(uint){
        return dataFeed.decimals();
    }

    /**
     * UTILITY FUNCTIONS FOR TESTING
     */
    function fundPolicy() external payable {
        capacity += msg.value;
    }
    function withdraw() payable public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
}
contract EthInsurance1000 is ConfirmedOwner {
    uint public ethPrice;
    uint256 public capacity;
    AggregatorV3Interface internal dataFeed;

    event PolicyPurchased(address indexed insuredAddress);
    event ClaimProcessed(address indexed insuredAddress, uint256 payoutAmount);

    struct Policy {
        uint256 premium;
        uint256 coverAmount;
        uint256 startDate;
        uint256 endDate;
        bool isClaimed;
    }
    mapping(address => Policy[]) public policies;

    constructor() ConfirmedOwner(msg.sender) {
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        capacity = 100 ether;
    }

    /**
     * CORE FUNCTIONALITY
     */
    function purchaseInsurance(uint _coverAmount, uint256 _durationDays) external payable {
        require(_durationDays <= 90, "Duration exceeds maximum of 3 months");
        require(_coverAmount <= capacity, "Coverage exceeds capacity!");
        uint256 premium = calculatePremium(_coverAmount,_durationDays);
        require(msg.value == premium, "Incorrect premium amount sent");

        Policy[] storage userPolicies = policies[msg.sender];

        if (userPolicies.length != 0){
            Policy storage latestPolicy = userPolicies[userPolicies.length-1];
            require(latestPolicy.isClaimed || latestPolicy.endDate<block.timestamp,"You have already purchased this policy.");
        }

        uint256 startDate = block.timestamp;
        uint256 endDate = startDate + (_durationDays * 1 days);
        capacity = capacity - _coverAmount + premium;

        Policy memory newPolicy;
        newPolicy.premium = premium;
        newPolicy.coverAmount = _coverAmount;
        newPolicy.startDate = startDate;
        newPolicy.endDate = endDate;
        newPolicy.isClaimed = false;

        userPolicies.push(newPolicy);

        emit PolicyPurchased(msg.sender);
    }
    function calculatePremium(uint _coverAmount, uint256 _durationDays) public pure returns (uint256) {
        // Simplified premium calculation logic, can use more sophisticated algorithms
        // based on the duration, risk models, etc.
        return _coverAmount;
    }
    function claim() external payable  {
        Policy[] storage userPolicies = policies[msg.sender];
        require(userPolicies.length>0,"You have not purchased this policy");
        Policy storage latestPolicy = userPolicies[userPolicies.length-1];

        require(latestPolicy.startDate <= block.timestamp && block.timestamp <= latestPolicy.endDate, "Policy not active");
        require(!latestPolicy.isClaimed, "Claim already processed");

        ethPrice = uint256(getEthPrice());
        require(ethPrice < 1000 * 10**getEthDecimalPlace(), "Ethereum price is not below $1000");

        // Perform claim processing logic...
        latestPolicy.isClaimed = true;
        // Transfer payout
        payable(msg.sender).transfer(latestPolicy.coverAmount);
        emit ClaimProcessed(msg.sender, latestPolicy.coverAmount);
    }
    function numPolicies(address userAddress) external view returns(uint256){
        return policies[userAddress].length;
    }

    /**
     * ORACLE FUNCTIONS
     */
    function getEthPrice() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    function getEthDecimalPlace() public view returns(uint){
        return dataFeed.decimals();
    }

    /**
     * UTILITY FUNCTIONS FOR TESTING
     */
    function fundPolicy() external payable {
        capacity += msg.value;
    }
    function withdraw() payable public onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
}