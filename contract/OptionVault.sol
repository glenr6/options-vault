// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./libraries/BlackScholes.sol";     - likely won't be included in the option contract --> pricing to occur off chain
import "./OptionToken.sol";
import "./PriceConsumerV3.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OptionVault is OptionToken, PriceConsumerV3 {

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

    address usdcAddress = 0xff970a61a04b1ca14834a43f5de4533ebddb5cc8;

 // @dev  may have to create a different function for depositing call and put collateral to manage the different assets required for this
    function depositCollateral(
        uint256 strikePrice;
        uint256 expirationDate; 
        uint256 underlyingValue;  
        string assetSymbol; 
        bool isCall;
        address counterpartyAddress;
    ) public payable {
        require(msg.value >= underlyingValue);
        optionId++;
        Option memory option = Option(strikePrice, expirationDate, underlyingValue, optionId, assetSymbol, isCall, counterpartyAddress);
        options.push(option);
        depositedCollateral[msg.sender] += msg.value;
        mintOption(Option.optionId);
    }

    // Events for option expiration and exercise
    event OptionExpired(uint256 optionId);
    event OptionExercised(uint256 optionId);
    event OptionBurned (uint256 optionId);


    function exerciseCallOption(uint256 _optionId) public returns(string) {
       
        require(msg.sender != address(0), "Can't exercise option from contract address");

        // Get the option details
        Option memory option = _getOption(_optionId);

        // Check if the user is the owner of the option NFT
        require(msg.sender == ownerOf(_optionId), "User own the NFT to exercise the option");

        require(option.isCall == true, "this is not a call option");
       

        // Check if the expiration date has passed --> see what exercis conditions apply in traditional markets and adjust timing logic accordingly
        require(option.expirationDate > block.timestamp && option.expiryDate < block.timestamp + 1 days, "Option is not in its one day exercisable window");

        // Check if the underlying asset price has been updated
        uint256 currentAssetPrice = getLatestPrice();
        require(currentAssetPrice > 0, "Underlying asset price must be retrieved before exercising the option");

        if(option.strikePrice <= currentAssetPrice) {
            // Check if the buyer has sufficient USDC to pay the strike price
            IERC20 usdc = IERC20(usdcAddress);
            require(usdc.balanceOf(msg.sender) >= option.strikePrice, "Buyer must have sufficient USDC to exercise at the strike price");
            
            // Transfer the USDC to the seller
            usdc.transfer(option.counterpartyAddress, option.strikePrice);

            // Transfer the underlying ETH to the buyer
            address buyerAddress = msg.sender;
            address sellerAddress = option.counterpartyAddress;
            uint256 underlyingValue = option.underlyingValue;
            require(sellerAddress.transfer(underlyingValue), "Transfer of underlying asset to buyer failed");

            // Remove the NFT from the buyer
            _burn(buyerAddress, _optionId);
            return "Option exercised successfully";
        } else {
            return "Option is out of the money";
        }
    }


    function exercisePutOption(uint256 _optionId) public returns(string) {
       
        require(msg.sender != address(0), "Can't exercise option from contract address");

        // Get the option details
        Option memory option = _getOption(_optionId);

        // Check if the user is the owner of the option NFT
        require(msg.sender == ownerOf(_optionId), "User must own the NFT to exercise the option");

        require(option.isCall == false, "This is not a put option");
       

        // Check if the expiration date has passed --> see what exercis conditions apply in traditional markets and adjust timing logic accordingly
        require(option.expirationDate > block.timestamp && option.expryDate < block.timestamp + 1 days, "Option is not in it's one day exercisable window");

        // Check if the underlying asset price has been updated
        uint256 currentAssetPrice = getLatestPrice();
        require(currentAssetPrice > 0, "Underlying asset price must be retrieved before exercising the option");

        if(option.strikePrice >= currentAssetPrice) {
            // The option is ITM, transfer the strike price to the buyer 
            uint256 usdcPrice = option.strikePrice;
            require(ERC20(usdcAddress).transfer(option.counterpartyAddress, usdcPrice), "USDC transfer failed");

            // Transfer the underlying value (eth) to the buyer/holder of the option NFT
            uint256 underlyingValue = option.underlyingValue;
            require(address(this).transfer(msg.sender, underlyingValue), "Underlying asset transfer failed");
        }
        return("Put option exercised successfully")
        
    }

    function expireOption(uint256 optionId) public {
        requires(optionId.counterpartyAddress == msg.sender, "You don't own this collateral");
        if block.timestamp > option.expirationDate && Option.counterpartyAddress == msg.sender ; 
        burn(optionId);
        msg.sender.transfer(underlyingValue);
        ownerOptionCount--;
        emit OptionExpired(optionId);
    }

    // burn function can only be initiaited by seller if he possesses the option token
    // i.e. he has not sold the NFT or has repurchased it from the mark
    function burnOption() public onlyOwnerOf(optionId) returns(bool) {
        reqire(ownerof[optionId] == msg.sender)
        burn(optionId);
        msg.sender.transfer(optionId.underlyingValue);
        emit OptionBurned(optionId);
    }
}