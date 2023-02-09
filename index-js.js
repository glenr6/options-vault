const { Arbitrum } = require("@arbitrum/web3");
const networkName = process.env.NETWORK_NAME;
const contractName = process.env.CONTRACT_NAME;

const arbitrum = new Arbitrum(`ws://localhost:8546`, {
    networkId: networkName,
});

module.exports = {
  networks: {
    [networkName]: {
      provider: arbitrum,
      network_id: process.env.NETWORK_ID,
    },
  },
  contracts: {
    CollateralVault.sol: {
    },
    ETHOption.sol :{

    }
    ]
  },
};