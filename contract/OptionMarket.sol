// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 

// @dev this contract will act as a limit orderbook where optionNFT holders can list their options and buyers an give an ask prie


import "./OptionToken.sol";
import "./OptionVault.sol";
import ".libraries/BlackScholes.sol";
import "libraries/DecimalMath.sol";

contract OptionMarket is OptionToken, OptionVault {
    
    struct Buyer public {
        address buyerAddress;
        uint256 optionCount;
    }

    struct Order {
        uint256 price;
        uint256 quantity;
        address owner;
    }

    mapping(address => Order) public bids;
    mapping(address => Order) public asks;

    event OrderPlaced(address indexed owner, uint256 price, uint256 quantity);
    event OrderCancelled(address indexed owner, uint256 price, uint256 quantity);
    event TradeExecuted(address indexed buyer, address indexed seller, uint256 price, uint256 quantity);

    modifier onlyOwner(address _owner) {
        require(msg.sender == _owner, "Only owner can perform this action");
        _;
    }

    modifier notForSale(address _owner) {
        require(bids[_owner].quantity == 0, "This option is already for sale");
        _;
    }

    function placeAsk(uint256 _price, uint256 _quantity) public notForSale(msg.sender) {
        asks[msg.sender] = Order({
            price: _price,
            quantity: _quantity,
            owner: msg.sender
        });
        emit OrderPlaced(msg.sender, _price, _quantity);

        // add token Id (optionId)
    }

    function placeBid(uint256 _price) public {
        uint256 askPrice = getLowestAskPrice();
        if (_price >= askPrice) {
            address seller = getLowestAskOwner();
            uint256 quantity = asks[seller].quantity;
            bids[msg.sender] = Order({
                price: _price,
                quantity: quantity,
                owner: msg.sender
            });
            asks[seller] = Order({
                price: 0,
                quantity: 0,
                owner: address(0)
            });
            emit TradeExecuted(msg.sender, seller, _price, quantity);
        } else {
            bids[msg.sender] = Order({
                price: _price,
                quantity: 1,
                owner: msg.sender
            });
            emit OrderPlaced(msg.sender, _price, 1);
        }
    }

    function cancelOrder(address _owner) public onlyOwner(_owner) {
        if (bids[_owner].quantity > 0) {
            uint256 price = bids[_owner].price;
            uint256 quantity = bids[_owner].quantity;
            bids[_owner] = Order({
                price: 0,
                quantity: 0,
                owner: address(0)
            });
            emit OrderCancelled(_owner, price, quantity);
        }
        if (asks[_owner].quantity > 0) {
            uint256 price = asks[_owner].price;
            uint256 quantity = asks[_owner].quantity;
            asks[_owner] = Order({
                price: 0,
                quantity: 0,
                owner: address(0)
            });
            emit OrderCancelled(_owner, price, quantity);
        }
    }

    function placeBid(uint256 _nftId, uint256 _price) public {
    require(msg.sender != ownerOf[_nftId], "Cannot place bid on own NFT");

    uint256 id = bids.push(Bid({
        id: bids.length,
        nftId: _nftId,
        bidder: msg.sender,
        price: _price
    })) - 1;

    emit BidPlaced(id, _nftId, msg.sender, _price);
}

function cancelBid(uint256 _bidId) public {
    Bid storage bid = bids[_bidId];
    require(bid.bidder == msg.sender, "Only the bidder can cancel the bid");

    bids[_bidId] = Bid({});
    emit BidCancelled(_bidId, bid.nftId, msg.sender, bid.price);
}

function buyAtMarketPrice(uint256 _nftId) public payable {
    uint256 marketPrice = getLowestAskPrice(_nftId);
    buyAtPrice(_nftId, marketPrice);
}

function buyAtPrice(uint256 _nftId, uint256 _price) private payable {
    Ask storage ask = asks[askIds[_nftId]];
    require(ask.nftId == _nftId, "NFT not for sale");
    require(ask.price == _price, "Price does not match ask price");
    require(ask.seller != msg.sender, "Cannot buy own NFT");
    require(msg.value >= _price, "Not enough ether to buy NFT");

    askIds[_nftId] = 0;
    asks[askIds[_nftId]] = Ask({});

    ownerOf[_nftId] = msg.sender;

    ask.seller.transfer(_price);

    emit NFTBought(_nftId, ask.seller, msg.sender, _price);
}

function getLowestAskPrice(uint256 _nftId) private view returns (uint256) {
    uint256 lowestAskPrice = 0;
    for (uint256 i = 0; i < asks.length; i++) {
        Ask storage ask = asks[i];
        if (ask.nftId == _nftId && (lowestAskPrice == 0 || ask.price < lowestAskPrice)) {
            lowestAskPrice = ask.price;
        }
    }
    return lowestAskPrice;
}


}