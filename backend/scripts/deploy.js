// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const productFacet = await hre.ethers.deployContract("ProductFacet");
  await productFacet.waitForDeployment();
  console.log(`productFacet deployed to ${productFacet.target}`);

  const ecmart = await hre.ethers.deployContract("Diamond");

  await ecmart.waitForDeployment();
  console.log(`ECMart Diamond deployed to ${ecmart.target}`);
  // console.log(ecmart);

  // const transactionResponse = await ecmart.addProduct(
  //   "Shirt",
  //   323,
  //   "Shirt polo",
  //   123
  // );
  // // const transactionResponse = await ecmart.getdata();

  // console.log(`Transaction  Response ${transactionResponse}`);
  // console.log(ecmart.interface);
  // const encodedFunctionData = ecmart.interface.encodeFunctionData(
  //   "addProduct(string,uint256,string,uint256)",
  //   ["Shirt", 323, "Shirt polo", 123]
  // );
  const { Web3 } = require("web3");

  // Connect to an Ethereum provider (replace with your Ethereum RPC URL)
  const web3 = new Web3("HTTP://127.0.0.1:7545");
  // var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'));

  // Define the private key or wallet that will sign the transaction
  const privateKey =
    "0x6efb9cfa62e1016acd0f990f84d637f70d1a70ab97d068deb8e9e107d7dae093";
  const account = web3.eth.accounts.privateKeyToAccount(privateKey);

  // Set the default account (sender)
  web3.eth.accounts.wallet.add(account);
  web3.eth.defaultAccount = account.address;

  // Define the address of the Diamond contract
  const diamondContractAddress = ecmart.target;

  // Define the function signature
  // const functionName = "addProduct(string,uint256,string,uint256)";
  const functionName = "getdata(uint256)";

  // Define the parameters for the addProduct function
  const productName = "Product Name";
  const productPrice = 100;
  const productDescription = "Product Description";
  const productQuantity = 10;

  // Calculate the function selector
  const functionSelector = web3.eth.abi.encodeFunctionSignature(functionName);

  // Encode the parameters
  const encodedParameters = web3.eth.abi.encodeParameters(
    // ["string", "uint256", "string", "uint256"],
    // [productName, productPrice, productDescription, productQuantity]
    ["uint256"],
    [2343234]

    // [],
    // []
  );

  // Combine the function selector and encoded parameters
  const data = functionSelector + encodedParameters.slice(2);
  console.log(data);
  // Create a transaction object
  const txObject = {
    to: diamondContractAddress,
    data: data,
    gas: 2000000, // Adjust the gas limit as needed
    gasPrice: web3.utils.toWei("50", "gwei"), // Adjust the gas price as needed
    nonce: await web3.eth.getTransactionCount(account.address),
  };

  // Sign and send the transaction
  web3.eth
    .sendTransaction(txObject)
    .on("transactionHash", (hash) => {
      console.log("Transaction Hash:", hash);
    })
    .on("receipt", (receipt) => {
      console.log("Transaction Receipt:", receipt);
      // const returnValue = web3.eth.abi.decodeParameter(
      //   "uint256",
      //   receipt.logs[0].data
      // );
      // console.log("Return Value:", returnValue);
    })
    .on("error", (error) => {
      console.error("Error:", error);
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
