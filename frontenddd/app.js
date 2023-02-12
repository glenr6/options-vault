import React, { useState } from 'react';
import Web3 from 'web3';

const Form = () => {
    const [strikePrice, setStrikePrice] = useState(undefined);
    const [assetName, setAssetName] = useState("ETH");
    const [underlyingValue, setunderlyingValue] = useState(100);

    const handleSubmit = () => {
        console.log("strikePrice", strikePrice);
        console.log("assetName", assetName);
        console.log("underlyingValue", underlyingValue);

        // Create an instance of the Web3 library
        const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

        // Define the contract ABI and address
        const contractABI = [...]
        const contractAddress = "0x..."

        // Create a contract instance
        const contractInstance = new web3.eth.Contract(contractABI, contractAddress);

        // Call the depositCollateral function of the contract
        // uint256 strikePrice, uint256 expirationDate, uint256 underlyingValue, string assetSymbol, bool isCall, address counterpartyAddress;
        try {
            const result = await contractInstance.methods.depositCollateral(strikePrice, expirationDate, underlyingValue, assetName, isCall, counterpartyAddress).send({ from: web3.eth.defaultAccount });
            console.log("Transaction successful: ", result);
        } catch (error) {
            console.error("Transaction failed: ", error);
        }
    };

    return (
        <form onSubmit={handleSubmit}>
            <label htmlFor="strikePrice">
                Strike Price:
                <input
                    type="text"
                    id="strikePrice"
                    value={strikePrice}
                    onChange={(e) => setStrikePrice(e.target.value)}
                />
            </label>
            <br />
            <br />
            <label htmlFor="assetName">
                Asset Name:
                <input
                    type="text"
                    id="assetName"
                    value={assetName}
                    onChange={(e) => setAssetName(e.target.value)}
                />
            </label>
            <br />
            <br />
            <label htmlFor="underlyingValue">
                Underlying Quantity:
                <input
                    type="number"
                    id="underlyingValue"
                    value={underlyingValue}
                    onChange={(e) => setunderlyingValue(e.target.value)}
                />
            </label>
            <br />
            <br />
            <button type="submit">Submit</button>
        </form>
    );
};

export default Form;


// Dashboard
// Buy
// Sell
// Open Trades
// Trade History

// Discord