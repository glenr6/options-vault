# options-vault
A decentralized options vault and marketplace on Arbitrum utilizing NFT positions

The OptionsVault contract serves as the central clearing house for American style options where collateral is sent and option NFTs are exercised by the buyer, or burned/expired by the seller. 

The OptionMarket contract is a limit order book where option NFTs can be listed and bought. Sellers are reccomended a price using the Black Scholes option pricing formula, however they can set the price to whatever they want because the pricing occors off chain (for now)

To mint and sell an option NFT, the seller calls the createOption function and sends the option information and collateral in a single transaction. They are immediately sent the NFT which they can list on our marketplace or sell to a private buyer in an OTC transaction

Please note this is just the first iteration of the product. It has not been audited and may not be secure.

--- 

Areas for future development

Support for more assets
Monetization:
  -  Fee for issuing option
  -  Fee on secondary trades
  -  Utilization of locked deposits (Staking, Overcollateralized Lending)
Improving Liquidity on Option Market
Privacy preservation - ZK SNARK to ensure counterparty is OFAC compliant without revealing address of counterparty to buyer
Updated pricing model: account for staking yield on ETH, improved proxy for IV 
Compliance with Securities Laws
