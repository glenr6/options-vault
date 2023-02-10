const OptionVault = artifacts.require("optionVault");

module.exports = function(deployer) {
  deployer.deploy(OptionVault.sol);
};
