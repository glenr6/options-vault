// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
// TODO: instead of _mint, use the _safeMint method from OpenZeppelin's ERC721.sol

contract OptionToken is ERC721, Ownable {
    string public name = getName(optionId);
    string public symbol = "ETHo"; 
    
    mapping (uint256 => Option) public options;
    Counters.Counter private _optionCounter;

    IERC20 USDC_Contract;
    
    struct Option {
        uint256 strikePrice;
        uint256 expirationDate;
        uint256 underlyingValue;
        uint256 optionId;
        string assetSymbol;
        bool isCall;
        address counterpartyAddress; // msg.sender 
    }

    constructor() {
        address USDC_Address = 0xff970a61a04b1ca14834a43f5de4533ebddb5cc8;
        USDC_Contract = IERC(USDC_Address);
    }

    function createOption(
        uint256 strikePrice,
        uint256 expirationDate,
        uint256 underlyingValue,
        string assetSymbol,
        bool isCall,
        address counterpartyAddress
    ) public payable {
        require(msg.value >= underlyingValue);

        uint256 memory optionId = _optionCounter.current();
        _optionCounter.increment();

        _mint(msg.sender, optionId);

        Option memory newOption = Option(
            strikePrice,
            expirationDate,
            underlyingValue,
            optionId,
            assetSymbol,
            isCall,
            counterpartyAddress
        );
        options[optionId] = newOption;

        // store the collateral in the contract
        depositedCollateral[msg.sender] += msg.value;
    }
    

    // TODO: return an Option struct
    // Function to retrieve the option data
    function getOption(uint256 id) public view returns (uint256, uint256, uint256, uint256, string memory, bool, address) {
        Option option = options[id];
        return (option.strikePrice, option.expirationDate, option.underlyingValue, option.optionId, option.assetSymbol, option.isCall, option.counterpartyAddress);
    }


    function exerciseCallOption(
        uint256 _optionId
    ) public returns(string) {

        // TODO: is this necessary?
        require(msg.sender != address(this),
            "Can't exercise option from contract address"
        );

        // Get the option details
        Option memory option = _getOption(_optionId);

        // Check if the user is the owner of the option NFT
        require(msg.sender == ownerOf(_optionId),
            "User must own the NFT to exercise the option"
        );

        require(option.isCall == true,
            "this is not a call option"
        );

        // Check if the expiration date has passed --> see what exercis conditions apply in traditional markets and adjust timing logic accordingly
        require(option.expirationDate > block.timestamp && option.expiryDate < block.timestamp + 1 days, "Option is not in its one day exercisable window");

        // Check if the underlying asset price has been updated
        uint256 currentAssetPrice = getLatestPrice();
        // TODO: is the line below necessary?
        require(currentAssetPrice > 0, "Underlying asset price must be retrieved before exercising the option");

        if(option.strikePrice <= currentAssetPrice) {
            // Check if the buyer has sufficient USDC to pay the strike price
            require(USDC_Contract.balanceOf(msg.sender) >= option.strikePrice, "Buyer must have sufficient USDC to exercise at the strike price");
            
            // Transfer the USDC to the seller
            // note: for this smart contract to be able to execute this function,
            // the caller should first approve the smart contract's address in the
            // USDC contract
            usdc.transfer(option.counterpartyAddress, option.strikePrice);

            // Transfer the underlying ETH to the buyer
            address buyerAddress = msg.sender;
            address sellerAddress = option.counterpartyAddress;
            uint256 underlyingValue = option.underlyingValue;
            require(sellerAddress.transfer(underlyingValue),
                "Transfer of underlying asset to buyer failed"
            );

            // Remove the NFT from the buyer
            burnOption(_optionId);
            return "Option exercised successfully";
        } else {
            return "Option is out of the money";
        }
    }

    // burn function can only be initiaited by seller if he possesses the option token
    // i.e. he has not sold the NFT or has repurchased it from the mark
    function burnOption(
        uint256 optionId
    ) public returns(bool) {
        require(ERC721.ownerOf(tokenId) == msg.sender)

        msg.sender.transfer(optionId.underlyingValue);

        _burn(optionId);

        emit OptionBurned(optionId);
    }
    
}
