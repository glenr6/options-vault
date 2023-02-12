// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
//import '@openzeppelin/contracts/utils/Counters.sol';
// TODO: instead of _mint, use the _safeMint method from OpenZeppelin's ERC721.sol

contract OptionToken is ERC721, Ownable {
    
    mapping (uint256 => Option) public options;
    //Counters.Counter private _optionCounter;
    uint256 _optionCounter;
    
    mapping (address => uint256) depositedCollateral;

    IERC721 USDC_Contract;
    
    struct Option {
        uint256 strikePrice;
        uint256 expirationDate;
        uint256 underlyingValue;
        uint256 optionId;
        string assetSymbol;
        bool isCall;
        address payable counterpartyAddress; // msg.sender 
    }

    constructor() ERC721("Option", "OPT") {
        // address on the Görli testnet (https://developers.circle.com/developer/docs/usdc-on-testnet#usdc-on-ethereum-goerli)
        address USDC_Address = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;
        USDC_Contract = IERC721(USDC_Address);
    }

    function createOption(
        uint256 strikePrice,
        uint256 expirationDate,
        uint256 underlyingValue,
        string memory assetSymbol,
        bool isCall
    ) public payable {
        require(msg.value >= underlyingValue);

        uint256 optionId = _optionCounter;
        _optionCounter++;

        _mint(msg.sender, optionId);

        Option memory newOption = Option(
            strikePrice,
            expirationDate,
            underlyingValue,
            optionId,
            assetSymbol,
            isCall,
            payable(msg.sender)
        );
        options[optionId] = newOption;

        // store the collateral in the contract
        depositedCollateral[msg.sender] += msg.value;
    }
    
    // Function to retrieve the option data
    function _getOption(uint256 id) internal view returns (Option memory) {
        return options[id];
    }

    function exerciseCallOption(
        uint256 _optionId
    ) public {

        // Get the option details
        Option memory option = _getOption(_optionId);

        // Check if the user is the owner of the option NFT
        require(msg.sender == ownerOf(_optionId),
            "User must own the NFT to exercise the option"
        );

        require(option.isCall == true,
            "this is not a call option"
        );

        // TODO: decide what to do with the /* */ section below 
        // Check if the expiration date has passed --> see what exercis conditions apply in traditional markets and adjust timing logic accordingly
        require(option.expirationDate + 1 days > block.timestamp/* && option.expirationDate < block.timestamp + 1 days*/,
            "Option is not in its one day exercisable window"
        );

        // does the USDC_Contract.transferFrom already have this check?
        // Check if the buyer has sufficient USDC to pay the strike price
        require(USDC_Contract.balanceOf(msg.sender) >= option.strikePrice,
            "Buyer must have sufficient USDC to exercise at the strike price"
        );
        
        // Transfer the USDC to the seller
        // note: for this smart contract to be able to execute this function,
        // the caller should first approve the smart contract's address in the
        // USDC contract
        USDC_Contract.transferFrom(
            msg.sender,
            option.counterpartyAddress,
            option.strikePrice
        );

        // TODO: learn how to check whether USDC transferFrom succeeded or not

        // Transfer the underlying ETH to the buyer
        option.counterpartyAddress.transfer(option.underlyingValue);

        // Remove the NFT from the buyer
        cancelOption(_optionId);
    }

    // TODO: should this function be public? would someone ever want to 
    // burn the option right away rather than waiting for it to expire?
    // i.e. he has not sold the NFT or has repurchased it from the market
    function cancelOption(
        uint256 optionId
    ) public isCounterparty(optionId) returns(bool) {
        require(
            ERC721.ownerOf(optionId) == msg.sender
        );

        _burn(optionId);

        return true;
    }

    function expireOption(
        uint256 optionId
    ) public isCounterparty(optionId) {
        Option memory option = _getOption(optionId);

        require(!isExecutable(option),
            "Cannot expire an option that is still executable"
        );

        payable(msg.sender).transfer(option.underlyingValue);
    }

    function isExecutable(Option memory option) internal view returns (bool) {
        return option.expirationDate + 1 days > block.timestamp;
    }

    modifier isCounterparty(uint256 optionId) {
        require(
            _getOption(optionId).counterpartyAddress == msg.sender
        );
        _;
    }

}