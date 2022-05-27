// SPDX-License-Identifier: MIT

pragma solidity ^0.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => int256) public addressToAmountFunded;
    AggregatorV3Interface internal priceFeed;
    address public owner;
    address[] public funders;

    constructor(address _priceFeed) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        int256 minimumUSD = 20 * 10**18;
        require(
            getConversionRate(int256(msg.value)) > minimumUSD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += int256(msg.value);
        funders.push(msg.sender);
    }

    function getVersion() public view returns (int256) {
        return int256(priceFeed.version());
    }

    function getPrice() public view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price * 10000000000;
        //176909129977
    }

    function getConversionRate(int256 ethAmount) public view returns (int256) {
        int256 ethPrice = getPrice();
        int256 ethAmountInUsd = (ethAmount * ethPrice) / 1000000000000000000;
        return ethAmountInUsd;
        //1769091299770
    }

    function getEntranceFee() public view returns (int256) {
        int256 minimumUSD = 20 * 10**18;
        int256 price = getPrice();
        int256 precision = 1 * 10**18;
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 index = 0; index < funders.length; index++) {
            address funder = funders[index];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
