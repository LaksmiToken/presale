// SPDX-License-Identifier: MIT
pragma solidity ^0.5.5;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@chainlink/contracts/src/v0.5/interfaces/AggregatorV3Interface.sol";

/**
 * @title LaksmiCrowdsale
 * @dev Laksmi Crowdsale where number of token is determined by pre-determined rate and current price of wei
 */
contract LaksmiCrowdsale is Crowdsale, Ownable, TimedCrowdsale {
    AggregatorV3Interface internal _priceFeed;
    uint256 internal _minToken;

    constructor(
        uint256 rate,
        address payable wallet,
        IERC20 token,
        uint256 openingTime,
        uint256 closingTime,
        uint256 minToken,
        AggregatorV3Interface priceFeed
    )
        public
        Crowdsale(rate, wallet, token)
        TimedCrowdsale(openingTime, closingTime)
        Ownable()
    {
        _priceFeed = priceFeed;
        _minToken = minToken;
    }

    function setMinToken(uint256 minToken) public onlyOwner {
        _minToken = minToken;
    }

    function extend(uint256 newClosingTime) public onlyOwner {
        _extendTime(newClosingTime);
    }

    /**
     * @dev Ether is converted to token based on the current price fetched by chainlink
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount)
        internal
        view
        returns (uint256)
    {
        (
            uint80 roundId,
            int256 price,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = _priceFeed.latestRoundData();
        uint256 tokenAmount = (weiAmount.mul(super.rate()).mul(uint256(price)))
        .div(100000000);
        require(tokenAmount >= _minToken, "Token amount is less than minimum");
        return tokenAmount;
    }
}
