// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract WeatherInsurance is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public precipitate;
    bytes32 private jobId;
    uint256 private fee;
    uint256 public capacity;

    event RequestPrecipitate(bytes32 indexed requestId, uint256 precipitate);
    event PolicyCreated(address indexed insuredAddress);
    event ClaimProcessed(address indexed insuredAddress, uint256 coverAmount);

    struct Policy {
        uint256 premium;
        uint256 coverAmount;
        uint256 startDate;
        uint256 endDate;
        uint256 latitude;
        uint256 longitude;
        bool isClaimed;
    }
    mapping(address => Policy[]) public policies;


    /**
     * @notice Initialize the link token and target oracle
     *
     * Sepolia Testnet details:
     * Link Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789
     * Oracle: 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
        capacity = 100 ether;
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestPrecipitateData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on
        req.add(
            "get",
            "https://api.open-meteo.com/v1/forecast?latitude=1&longitude=103&daily=precipitation_sum&timezone=auto&past_days=7&forecast_days=1"
        );

        req.add("path", "daily,precipitation_sum,2"); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 1000000000000000000 to remove decimals
        int256 timesAmount = 10 ** 18;
        req.addInt("times", timesAmount);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId,uint256 _precipitate) public recordChainlinkFulfillment(_requestId) {
        precipitate = _precipitate;
        emit RequestPrecipitate(_requestId, _precipitate);
    }

    function purchaseInsurance(uint256 _coverAmount, uint256 _durationDays, uint _lat, uint _lon) external payable {
        require(_durationDays <= 90, "Duration exceeds maximum of 3 months");
        require(_coverAmount <= capacity, "Cover amount exceeds capacity!");

        // Simplified premium calculation based on coverage amount and risk assessment
        uint256 premium = calculatePremium(_durationDays,_coverAmount);
        require(msg.value == premium, "Incorrect premium amount sent");

        Policy[] storage userPolicies = policies[msg.sender];

        if (userPolicies.length != 0){
            Policy storage latestPolicy = userPolicies[userPolicies.length-1];
            require(latestPolicy.endDate>block.timestamp,"You have already purchased this policy.");
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
        newPolicy.latitude = _lat;
        newPolicy.longitude = _lon;
        newPolicy.isClaimed = false;

        //creating the new policy
        userPolicies.push(newPolicy);

        emit PolicyCreated(msg.sender);
    }

    function calculatePremium(uint _durationDays,uint256 _coverAmount) public  pure returns (uint256) {
        // Simplified premium calculation logic
        // based on historical weather data, risk models, etc.
        return _coverAmount; 
    }

    function claim() external payable {
        Policy[] storage userPolicies = policies[msg.sender];
        require(userPolicies.length>0,"You have not purchased this policy");
        Policy storage latestPolicy = userPolicies[userPolicies.length-1];

        require(latestPolicy.startDate <= block.timestamp && block.timestamp <= latestPolicy.endDate, "Policy not active");
        require(!latestPolicy.isClaimed, "Claim already processed");

        // Example: Use the oracle to check the weather conditions
        // bool isBadWeather = weatherOracle.isBadWeather();
        require(precipitate == 0, "Drought have have not occured");

        // Perform claim processing logic...
        latestPolicy.isClaimed = true;
        payable(msg.sender).transfer(latestPolicy.coverAmount);
        emit ClaimProcessed(msg.sender, latestPolicy.coverAmount);
    }

    function numPolicies(address userAddress) external view returns(uint256){
    return policies[userAddress].length;
    }

    function fundPolicy() public payable {
        capacity += msg.value;
    }
    function withdraw() onlyOwner public payable {
        payable(msg.sender).transfer(address(this).balance);
    }
        /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}