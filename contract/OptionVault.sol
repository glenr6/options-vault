// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libraries/BlackScholes.sol";
import "./OptionToken.sol";
import "./PriceConsumerV3.sol";

contract OptionVault is BlackScholes, OptionToken, PriceConsumerV3 {

    struct Seller {
        uint256 depositedCollateral;
        address counterpartyAddress;
    }

    mapping (uint256 => address) optionToOwner;
    mapping (address => uint) ownerOptionCount;
    mapping (address => uint256) depositedCollateral;

    struct Option {
        uint256 strikePrice; // input from user
        uint256 expirationDate; // measured in seconds from unix epoch
        uint256 underlyingValue; // amount covered by option contract, measured in ETH
        uint256 optionId; 
        string assetSymbol; 
        bool isCall;
        address counterpartyAddress;
    }
    
    Option[] public options;

    modifier onlyOwnerOf(uint optionId) {
        require(msg.sender == optionToOwner[optionId]);
    _;

    function depositCollateral (
        uint256 strikePrice;
        uint256 expirationDate; 
        uint256 underlyingValue;  
        string assetSymbol; 
        bool isCall;
        address counterpartyAddress;
    ) public payable {
        require(msg.value >= underlyingValue);
        Option memory option = Option(strikePrice, expirationDate, underlyingValue, optionId, assetSymbol, isCall, counterpartyAddress);
        options.push(option);
        depositedCollateral[msg.sender] += msg.value;
        mintOption(Option.optionId);
        optionId++;
    }

    // Events for option expiration and exercise
    event OptionExpired(uint256 optionId);
    event OptionExercised(uint256 optionId);


    function exerciseCallOption(uint256 _optionId) public {
    require(msg.sender != address(0), "Can't exercise option from contract address");

    // Check if the user is the owner of the option NFT
    require(msg.sender == ownerOf(_optionId), "User own the NFT to exercise the option");

    // Get the option details
    Option memory option = _getOption(_optionId);

    // Check if the expiration date has passed --> see what exercis conditions apply in traditional markets and adjust timing logic accordingly
    require(option.expirationDate > block.timestamp && option.expryDate < block.timestamp + 1 days, "Option is not in it's one day exercisable window");

    // Check if the underlying asset price has been updated
    uint256 currentAssetPrice = getLatestPrice();
    require(currentAssetPrice > 0, "Underlying asset price must be retrieved before exercising the option");
    
            // Call ITM and execution Logic
    }

    function expireOption(uint256 optionId) public {
        requires(optionId.counterpartyAddress == msg.sender, "You don't own this collateral");
        if block.timestamp > option.expirationDate && Option.counterpartyAddress == msg.sender ; 
        burn(optionId);
        msg.sender.transfer(underlyingValue);
        ownerOptionCount--;

    }

    // burn function can only be initiaited by seller if he possesses the option token
    // i.e. he has not sold the NFT.  
    function burnOption() public onlyOwnerOf(optionId) returns(bool) {
        reqire(ownerof[optionId] == msg.sender)
        burn(optionId);
        msg.sender.transfer(optionId.underlyingValue);
    }
}