const OptionToken = artifacts.require("OptionToken");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(OptionToken.sol, OptionVault.address);
};
