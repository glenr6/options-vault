import { ethers } from "hardhat";

async function main() {
  // deploy the decrypt verifier
  const Token = await ethers.getContractFactory("OptionToken");
  const token = await Token.deploy();
  await token.deployed();
  console.log(
    `OptionToken.sol deployed to ${token.address}. Time: ${Date.now()}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
