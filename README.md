# options-vault
A decentralized options vault and marketplace on Arbitrum utilizing NFT positions

The OptionsVault contract serves as the central clearing house where collateral is sent and option NFTs are exercised by the buyer, or burned/expired by the seller. 

The OptionMarket contract is a limit order book where option NFTs can be listed and bought. Sellers are reccomended a price using the Black Scholes option pricing formula, however they can set the price to whatever they want because the pricing occors off chain (for now)

To mint and sell an option NFT, the seller calls the createOption function and sends the option information and collateral in a single transaction. They are immediately sent the NFT which they can list on our marketplace or sell to a private buyer in an OTC transaction

Please note this is just the first iteration of the product. It has not been audited and may not be secure.
