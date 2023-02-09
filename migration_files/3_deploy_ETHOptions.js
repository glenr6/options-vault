const OptionsContract = artifacts.require("OptionsContract");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(ETHOptions, CollateralVault.address);
};
