// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  // const Product = await hre.ethers.getContractFactory("Product");
  // console.log("Deploying contract...");
  // const product = await Product.deploy(
  //   "win",
  //   "2656",
  //   "Win is the hottest boy to buy",
  //   "1",
  //   "0x7a68a980FB95dAE6E0Cd4b92951e2363ED07da4A",
  //   "0xAD2Ba2c788B73788db4BC597146f0Fd6176285C8"
  // );
  // // await product.deployed();
  // console.log(`Deployed contract to: ${product.address}`);

  //   const product = await hre.ethers.deployContract("Product", [
  //     "win",
  //     "2656",
  //     "Win is the hottest boy to buy",
  //     "1",
  //     "0x7a68a980FB95dAE6E0Cd4b92951e2363ED07da4A",
  //     "0xAD2Ba2c788B73788db4BC597146f0Fd6176285C8",
  //   ]);

  //   await product.waitForDeployment();
  //   // console.log(product);
  //   console.log(`Product deployed to ${product.target}`);
  // }

  const ecmart = await hre.ethers.deployContract("ECMart");

  await ecmart.waitForDeployment();
  // console.log(product);
  console.log(`Product deployed to ${ecmart.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
