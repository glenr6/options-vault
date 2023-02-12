// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OptionVault.sol";

contract OptionMarket {
    // Importing the OptionVault contract
    OptionVault public optionVault;

    // Struct to store order information
    struct Order {
        uint256 optionId;
        uint256 strikePrice;
        uint256 expirationDate;
        uint256 underlyingValue;
        string assetSymbol;
        bool isCall;
        address counterpartyAddress;
        address buyer;
        uint256 price;
        uint256 quantity;
        uint256 orderType; // 1 = Bid, 2 = Ask
    }

    // Mapping to store the order information
    mapping(uint256 => Order) public orderMap;
    uint256 public orderCount;

    // Event to emit when an order is placed
    event OrderPlaced(
        uint256 indexed optionId,
        uint256 indexed strikePrice,
        uint256 indexed expirationDate,
        uint256 indexed underlyingValue,
        string assetSymbol,
        bool isCall,
        address counterpartyAddress,
        address buyer,
        uint256 price,
        uint256 quantity,
        uint256 orderType
    );

    // Event to emit when an order is executed
    event OrderExecuted(
        uint256 indexed optionId,
        uint256 indexed strikePrice,
        uint256 indexed expirationDate,
        uint256 indexed underlyingValue,
        string assetSymbol,
        bool isCall,
        address counterpartyAddress,
        address buyer,
        uint256 price,
        uint256 quantity,
        uint256 orderType
    );

    // Event to emit when an order is cancelled
    event OrderCancelled(
        uint256 indexed optionId,
        uint256 indexed strikePrice,
        uint256 indexed expirationDate,
        uint256 indexed underlyingValue,
        string assetSymbol,
        bool isCall,
        address counterpartyAddress,
        address buyer,
        uint256 price,
        uint256 quantity,
        uint256 orderType
    );

    // Constructor to initialize the OptionVault contract
    constructor(address _optionVault) public {
        optionVault = OptionVault(_optionVault);
    }

    // Function to place a bid order
    function placeBidOrder(
        uint256 _optionId,
        uint256 _price,
        uint256 _quantity
    ) public {
        // Get the option information from the OptionVault contract
        Option memory option = optionVault.optionMap[_optionId];

        // Store the order information in the orderMap
        orderMap[orderCount] = Order(
            _optionId,
            option.strikePrice,
            option.expirationDate,
            option.underlyingValue,
            option.assetSymbol,
            option.isCall,
            option.counterpartyAddress,
            msg.sender,
            _price,
            _quantity,
            1
        );

        // Emit the OrderPlaced event
        emit OrderPlaced(
            _optionId,
            option.strikePrice,
            option.expirationDate,
            option.underlyingValue,
            option.assetSymbol,
            option.isCall,
            option.counterpartyAddress,
            msg.sender,
            _price,
            _quantity,
            1
        );

        // Increment the orderCount
        orderCount++;
    }

    // Function to place an ask order
    function placeAskOrder(
        uint256 _optionId,
        uint256 _price,
        uint256 _quantity
    ) public {
        // Get the option information from the OptionVault contract
        Option memory option = optionVault.optionMap[_optionId];

        // Store the order information in the orderMap
        orderMap[orderCount] = Order(
            _optionId,
            option.strikePrice,
            option.expirationDate,
            option.underlyingValue,
            option.assetSymbol,
            option.isCall,
            option.counterpartyAddress,
            msg.sender,
            _price,
            _quantity,
            2
        );

        // Emit the OrderPlaced event
        emit OrderPlaced(
            _optionId,
            option.strikePrice,
            option.expirationDate,
            option.underlyingValue,
            option.assetSymbol,
            option.isCall,
            option.counterpartyAddress,
            msg.sender,
            _price,
            _quantity,
            2
        );

        // Increment the orderCount
        orderCount++;
    }

    // Function to execute an order
    function executeOrder(uint256 _orderId) public {
        // Get the order information from the orderMap
        Order storage order = orderMap[_orderId];

        // Check if the order is still available
        require(order.quantity > 0, "Order not available"); // TODO: check if we need to require order qty less than amount

        // Transfer the NFT to the buyer
        optionVault.transferFrom(
            order.counterpartyAddress,
            order.buyer,
            order.optionId
        );

        // Decrement the quantity of the order
        order.quantity--;

        // Emit the OrderExecuted event
        emit OrderExecuted(
            order.optionId,
            order.strikePrice,
            order.expirationDate,
            order.underlyingValue,
            order.assetSymbol,
            order.isCall,
            order.counterpartyAddress,
            order.buyer,
            order.price,
            order.quantity,
            order.orderType
        );
    }

    // Function to cancel an order
    function cancelOrder(uint256 _orderId) public {
        // Get the order information from the orderMap
        Order storage order = orderMap[_orderId];

        // Emit the OrderCancelled event
        emit OrderCancelled(
            order.optionId,
            order.strikePrice,
            order.expirationDate,
            order.underlyingValue,
            order.assetSymbol,
            order.isCall,
            order.counterpartyAddress,
            order.buyer,
            order.price,
            order.quantity,
            order.orderType
        );

        // Delete the order information from the orderMap
        delete orderMap[_orderId];
    }

    // Function to buy an option NFT at market price
    function buyAtMarketPrice(uint256 _optionId) public {
        // Get the lowest ask price for the option NFT
        uint256 lowestAskPrice = getLowestAskPrice(_optionId);

        // Loop through the orderMap to find the lowest ask price
        for (uint256 i = 0; i < orderCount; i++) {
            Order storage order = orderMap[i];

            // Check if the order is an ask order and the optionId matches
            if (order.orderType == 2 && order.optionId == _optionId) {
                // Check if the price of the order is the lowest ask price
                if (order.price == lowestAskPrice) {
                    // Execute the order
                    executeOrder(i);
                    return;
                }
            }
        }
    }

    // Function to get the lowest ask price for an option NFT
    function getLowestAskPrice(uint256 _optionId)
        public
        view
        returns (uint256)
    {
        require(asks.length > 0, "There are no options for sale");
        uint256 lowestAskPrice = asks[0].price;

        // Loop through the orderMap to find the lowest ask price
        for (uint256 i = 0; i < orderCount; i++) {
            Order storage order = orderMap[i];

            // Check if the order is an ask order and the optionId matches
            if (order.orderType == 2 && order.optionId == _optionId) {
                // Check if the price of the order is less than the current lowest ask price
                if (order.price < lowestAskPrice) {
                    lowestAskPrice = order.price;
                }
            }
        }

        return lowestAskPrice;
    }

    function getHighestBidPrice(uint256 _optionId)
        public
        view
        returns (uint256)
    {
        uint256 highestBidPrice = 0;

        // Loop through the orderMap to find the highest bid price
        for (uint256 i = 0; i < orderCount; i++) {
            Order storage order = orderMap[i];

            // Check if the order is a bid order and the optionId matches
            if (order.orderType == 1 && order.optionId == _optionId) {
                // Check if the price of the order is greater than the current highest bid price
                if (order.price > highestBidPrice) {
                    highestBidPrice = order.price;
                }
            }
        }

        return highestBidPrice;
    }

    function sellAtMarketPrice(uint256 _optionId) public payable {
        // Get the highest bid price for the option NFT
        uint256 highestBidPrice = getHighestBidPrice(_optionId);

        // Loop through the orderMap to find the highest bid price
        for (uint256 i = 0; i < orderCount; i++) {
            Order storage order = orderMap[i];

            // Check if the order is a bid order and the optionId matches
            if (order.orderType == 1 && order.optionId == _optionId) {
                // Check if the price of the order is the highest bid price
                if (order.price == highestBidPrice) {
                    // Execute the order
                    executeOrder(i);
                    return;
                }
            }
        }
    }
}
