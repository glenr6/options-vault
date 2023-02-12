// Load the Web3.js library
var Web3 = require('web3');

// Connect to the Ethereum network
var web3 = new Web3(new Web3.providers.HttpProvider("https://mainnet.infura.io/v3/YOUR-PROJECT-ID"));

// ABI (Application Binary Interface) for the NFT contract
var abi = [ ... ];

// Address of the deployed NFT contract
var contractAddress = "0x1234567890123456789012345678901234567890";

// Create a contract object
var contract = new web3.eth.Contract(abi, contractAddress);

// ID of the option to retrieve
var optionId = 1;

// Call the getOption function
contract.methods.getOption(optionId).call(function(error, result) {
    if (error) {
        console.error(error);
    } else {
        // Generate the JSON file in the ERC721 Metadata JSON Schema format
        var metadata = {
            "name": "oETH",
            "description": "This is an Opti finance Option contract NFT.",
            "image": "____________________",
            "external_url": "________________",
            "attributes": [
                { "key": "strikePrice", "value": result[0].toString() },
                { "key": "expirationDate", "value": result[1].toString() },
                { "key": "underlyingValue", "value": result[2].toString() },
                { "key": "optionId", "value": result[3].toString() },
                { "key": "assetSymbol", "value": result[4] },
                { "key": "isCall", "value": result[5]},
                {"key": "counterpartyAddress", "value": result[6].toString()},
            ]
        };
        console.log(JSON.stringify(metadata, null, 6));
    }
});