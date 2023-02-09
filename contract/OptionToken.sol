// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OptionToken is ERC721, Ownable, ERC721Burnable {
    string public name = "Option Token"; // amount asset strike call/put option date
    string public symbol = "ETH Option"; 
    
    mapping (uint256 => Option) public options;
    uint256 optionId;
    
    struct Option {
        uint256 strikePrice;
        uint256 expirationDate;
        uint256 underlyingValue;
        uint256 optionId;
        string assetSymbol;
        bool isCall;
        address counterpartyAddress; // msg.sender 
    }
    

    function mintOption(Option option) internal returns (bool) {
        _mint(msg.sender, option.optionId);
        strikePrice = option.strikePrice;
        expirationDate = option.expirationDate;
        underlyingValue = option.underlyingValue;
        assetSymbol = option.assetSymbol;
        isCall = option.isCall;
        counterpartyAddress = option.counterpartyAddress;
        nextTokenId();
        return true;
    }

    function nextTokenId() private returns (uint256) {
        return optionId++;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return super.balanceOf(_owner);
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        return super.ownerOf(_tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_from == ownerOf(_tokenId), "The from address must be the owner of the token");
        require(_to != address(0), "The to address cannot be the zero address");
        require(_tokenId != 0, "The token ID cannot be 0");
        require(optionToOwner[_tokenId] == _from, "The token must be associated with the from address");
        
        // transfer ownership
        optionToOwner[_tokenId] = _to;
        ownerOptionCount[_from]--;
        ownerOptionCount[_to]++;

        // emit transfer event
        emit Transfer(_from, _to, _tokenId);
    }

    // Function to retrieve the option data
    function getOption(uint256 id) public view returns (uint256, uint256, uint256, uint256, string memory, bool, address) {
        Option option = options[id];
        return (option.strikePrice, option.expirationDate, option.underlyingValue, option.optionId, option.assetSymbol, option.isCall, option.counterpartyAddress);
    }
}