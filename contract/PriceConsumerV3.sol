// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Arbitrum
     * Aggregator: ETH/USD
     * Address: 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612);
    }

    // Returns the latest price
    function getLatestPrice() public view returns (uint256) {
        (
            /* uint80 roundID */,
            uint256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }
}
