// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title PriceConsumerV3
 * @dev Contract for consuming price feeds from Chainlink oracles
 */
contract PriceConsumerV3 {
    AggregatorV3Interface internal priceFeed;

    /**
     * @dev Constructor that initializes the price feed contract
     * @param _priceFeedAddress The address of the Chainlink price feed
     */
    constructor(address _priceFeedAddress) {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    /**
     * @dev Returns the latest price from the price feed
     * @return The latest price in USD with 8 decimals
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            int256 price,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }

    /**
     * @dev Converts an amount to USD value using the price feed
     * @param amount The amount to convert
     * @param decimals The number of decimals for the amount
     * @return The USD value with 8 decimals
     */
    function convertToUSD(uint256 amount, uint8 decimals) public view returns (uint256) {
        int256 price = getLatestPrice();
        uint256 amountInWei = amount * (10 ** (18 - decimals));

        // Chainlink price feeds typically have 8 decimals
        return (amountInWei * uint256(price)) / (10 ** 8);
    }

    /**
     * @dev Returns price feed description
     * @return The description of the price feed
     */
    function getDescription() public view returns (string memory) {
        return priceFeed.description();
    }

    /**
     * @dev Returns the decimals of the price feed
     * @return The number of decimals
     */
    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
}

