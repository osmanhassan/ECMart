//  -----------------------------
// let tx = await productFacet.getdata(5);
// console.log(`Got value from ProductFacet Function ${tx}`);

// console.log(tx_2);

//addProduct eventListener
// productFacet.on("Save", (_productAddress) => {
//   console.log("Product added to ---->" + _productAddress);
// });

//  ---------------------------

// -------------------------------
// const productFacet = await hre.ethers.deployContract("ProductFacet");
// await productFacet.waitForDeployment();
// console.log(`productFacet deployed to ${productFacet.target}`);
// const ecmart = await hre.ethers.deployContract("Diamond");

// await ecmart.waitForDeployment();
// console.log(`ECMart Diamond deployed to ${ecmart.target}`);
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

// ----------------------

// ----------------------

// const { Web3 } = require("web3");

// // Connect to an Ethereum provider (replace with your Ethereum RPC URL)
// const web3 = new Web3("HTTP://127.0.0.1:7545");
// // var web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545'));

// // Define the private key or wallet that will sign the transaction
// const privateKey =
//   "0x03e63cfbe537b221ac06325117d71b4473933df253a0d94664b38a3056c2a76e";
// const account = web3.eth.accounts.privateKeyToAccount(privateKey);

// // Set the default account (sender)
// web3.eth.accounts.wallet.add(account);
// web3.eth.defaultAccount = account.address;

// // Define the address of the Diamond contract
// const diamondContractAddress = ecmart.target;

// // Define the function signature
// // const functionName = "addProduct(string,uint256,string,uint256)";
// const functionName = "getdata(uint256)";

// // Define the parameters for the addProduct function
// const productName = "Product Name";
// const productPrice = 100;
// const productDescription = "Product Description";
// const productQuantity = 10;

// // Calculate the function selector
// const functionSelector = web3.eth.abi.encodeFunctionSignature(functionName);

// // Encode the parameters
// const encodedParameters = web3.eth.abi.encodeParameters(
//   // ["string", "uint256", "string", "uint256"],
//   // [productName, productPrice, productDescription, productQuantity]
//   ["uint256"],
//   [2343234]

//   // [],
//   // []
// );

// // Combine the function selector and encoded parameters
// console.log("------------ ", encodedParameters);
// const data = functionSelector + encodedParameters.slice(2);
// // console.log(data);
// // Create a transaction object
// const txObject = {
//   to: diamondContractAddress,
//   data: data,
//   gas: 200000000, // Adjust the gas limit as needed
//   gasPrice: web3.utils.toWei("50", "gwei"), // Adjust the gas price as needed
//   nonce: await web3.eth.getTransactionCount(account.address),
// };

// // Sign and send the transaction
// web3.eth
//   .sendTransaction(txObject)
//   .on("transactionHash", (hash) => {
//     console.log("Transaction Hash:", hash);
//   })
//   .on("receipt", (receipt) => {
//     console.log("Transaction Receipt:", receipt);
//     // const returnValue = web3.eth.abi.decodeParameter(
//     //   "uint256",
//     //   receipt.logs[0].data
//     // );
//     // console.log("Return Value:", returnValue);
//   })
//   .on("error", (error) => {
//     console.error("Error:", error);
//   })
