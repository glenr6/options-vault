const CollateralVault = artifacts.require("CollateralVault");

module.exports = function(deployer) {
  deployer.deploy(CollateralVault.sol);
};
