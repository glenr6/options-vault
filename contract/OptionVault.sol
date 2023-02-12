// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '/libraries/PriceConsumerV3.sol';
// import '@openzeppelin/contracts/utils/Counters.sol';
// TODO: instead of _mint, use the _safeMint method from OpenZeppelin's ERC721.sol

contract OptionVault is ERC721, Ownable {
    
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
        address USDC_Address = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
        USDC_Contract = IERC721(USDC_Address);
    }

    function createCallOption(
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

    function createPutOption(
            uint256 strikePrice,
            uint256 expirationDate,
            uint256 underlyingValue,
            string memory assetSymbol,
            bool isCall
        ) public payable {
            // Check if the user has approved the contract to spend the required amount of USDC
            require(usdcAddress.allowance(msg.sender, address(this)), "You must approve the contract as a receiver for the required USDC");

            // Check if the user has sent enough USDC in the transaction to cover the collateral requirement
            require(usdcAddress.transferFrom(msg.sender, address(this), strikePrice * underlyingValue), "You must send enough USDC to cover the collateral requirement for this put option");

            int256 optionId = _optionCounter;
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
        }

    
        // Function to retrieve the option data
        function _getOption(uint256 optionId) internal view returns (Option memory) {
            return options[optionId];
        }

        function exerciseCallOption(
            uint256 _optionId
        ) public {

        Option memory option = _getOption(_optionId);

        // Check if the user is the owner of the option NFT
        require(msg.sender == ownerOf(_optionId), "User must own the NFT to exercise the option");

        require(option.isCall == true, "this is not a call option");

        require(isExecutable(option), "Option is not in the exercisable window");

        // Check if the buyer has sufficient USDC to pay the strike price
        require(USDC_Contract.balanceOf(msg.sender) >= option.strikePrice,"Buyer must have sufficient USDC to exercise at the strike price" );
        
        // Transfer the USDC to the option writer.  note: for this smart contract to be able to execute
        // this function, the caller must approve the counterparty's address in the USDC contract
        USDC_Contract.transferFrom(msg.sender,option.counterpartyAddress, option.strikePrice);

        // Transfer the underlying ETH to the buyer
        option.counterpartyAddress.transfer(option.underlyingValue);

        // Remove the NFT from the buyer
        cancelOption(_optionId);
    }

    function exercisePutOption(uint256 _optionId) public returns(string) {
       
        require(msg.sender != address(0), "Can't exercise option from contract address");

        // Get the option details
        Option memory option = _getOption(_optionId);

        // Check if the user is the owner of the option NFT
        require(msg.sender == ownerOf(_optionId), "User must own the NFT to exercise the option");

        require(option.isCall == false, "This is not a put option");

        require(isExecutable(option), "Option is not in the exercisable window");


        uint256 usdcPrice = option.strikePrice;
        require(ERC20(usdcAddress).transfer(option.counterpartyAddress, usdcPrice), "USDC transfer failed");

        // Transfer the underlying value (eth) to the buyer/holder of the option NFT
        uint256 underlyingValue = option.underlyingValue;
        require(address(this).transfer(msg.sender, underlyingValue), "Underlying asset transfer failed");
    
        return("Put option exercised successfully")
        
    }


    // for seller to burn and return his collateral if he has not sold the NFT (or has repurchased it from the market)
    function cancelOption(
        uint256 optionId
    ) public isCounterparty(optionId) returns(bool) {
        require(
            ERC721.ownerOf(optionId) == msg.sender
        );
        _burn(optionId);
        return true;
    }

    // function for counterparty to withdraw their collateral when their option is expired
    function expireOption(
        uint256 optionId
    ) public isCounterparty(optionId) {}
        Option memory option = _getOption(optionId);
        require(!isExecutable(option),
            "Cannot expire an option that is still executable"
        );

        payable(msg.sender).transfer(option.underlyingValue);
    }

    function isExecutable(Option memory option) internal view returns (bool) {
        return option.expirationDate <= block.timestamp;
    }

    modifier isCounterparty(uint256 optionId) {
        require(
            _getOption(optionId).counterpartyAddress == msg.sender
        );
        _;
    }

}