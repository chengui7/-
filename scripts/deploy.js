// Hardhat deploy script (example)
const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const routerAddress = process.env.ROUTER_ADDRESS; // e.g. UniswapV2 router
  const marketingWallet = process.env.MARKETING_WALLET;
  if (!routerAddress || !marketingWallet) {
    throw new Error("Set ROUTER_ADDRESS and MARKETING_WALLET in .env before deploying");
  }

  const initialSupply = hre.ethers.utils.parseUnits("1000000", 18); // 1,000,000 tokens

  const DarkButterfly = await hre.ethers.getContractFactory("DarkButterfly");
  const token = await DarkButterfly.deploy("DarkButterfly", "DBFLY", initialSupply, routerAddress, marketingWallet);
  await token.deployed();

  console.log("Token deployed to:", token.address);
  console.log("Set the pair address (AMM) and add liquidity manually via router/pair factory.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
