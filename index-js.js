const { Arbitrum } = require("@arbitrum/web3");
const networkName = process.env.arbitrumNova;
const contractName = process.env.OptionVault.sol;
const contractName = process.env.OptionMarketV1.2.sol;

const arbitrum = new Arbitrum(`ws://localhost:8546`, {
    networkId: arbitrumNova,
});

module.exports = {
  networks: {
    [Arbitrum Nova]: {
      provider: arbitrum,
      network_id: process.env.42161,
    },
  },
  contracts: {
    OptionVault.sol: {
    },
    OptionMarketV1.2.sol :{

    }
    ]
  },
};
