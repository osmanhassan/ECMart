// buyer order --> Seller Accept  --> Deliverymamn Accept   -->   Buyer Pay   -->   Contract Deploy

// COntract definition 
contract Ecmart {
   private deliverycharge = [[will be set dynamically from code]]
   private sellerAddress = [[will be set dynamically from code]]  
   private deliverymanAddress = [[will be set dynamically from code]]  
   private meanRollBackDuration = [[will be set dynamically from code]]  
   private isPaid = false;

   public pay (){
      if(owner == _msg.sender){
         sellerAddress.transfer((address)this.balance - deliverycharge);
         deliverymanAddress.transfer(deliverycharge);
         isPaid = true;
      }
   }

   public rollback(){
      if(owner == _msg.sender && (this.creationTime - currentTime ) >= meanRollBackDuration && !isPaid){
         owner.transfer((address)this.balance);
      }
   }

}


//using above SOLIDITY code make smart contract and deploy it using web3.js by signing with the private key of BUYER and STORE the address of the contract  

// DONE AND DUSTED, bitches


/* Web3.js part to transfer balance from buyer to contract   */

const Web3 = require("web3");

// Connect to a local Ethereum node or a network
const web3 = new Web3("http://localhost:8545"); // Replace with your Ethereum node URL

// The address of the smart contract
const contractAddress = "0xContractAddress"; // Replace with your contract address

// The private key of the sender's account
const privateKey = "0xYourPrivateKey"; // Replace with your private key

// Create a wallet from the private key
const senderWallet = web3.eth.accounts.privateKeyToAccount(privateKey);

// The recipient address (smart contract address)
const recipientAddress = contractAddress;

// The amount of Ether to send (in Wei)
const amountToSend = web3.utils.toWei("1", "ether"); // Sending 1 Ether

// Build the transaction object
const txObject = {
  to: recipientAddress,
  value: amountToSend,
  gas: 21000, // Gas limit for sending Ether
  gasPrice: web3.utils.toWei("10", "gwei"), // Gas price in Gwei
};

// Sign and send the transaction
web3.eth.accounts
  .signTransaction(txObject, senderWallet.privateKey)
  .then((signedTx) => {
    web3.eth
      .sendSignedTransaction(signedTx.rawTransaction)
      .on("transactionHash", (hash) => {
        console.log(`Transaction hash: ${hash}`);
      })
      .on("receipt", (receipt) => {
        console.log("Transaction receipt:", receipt);
      })
      .on("error", (error) => {
        console.error("Transaction error:", error);
      });
  })
  .catch((error) => {
    console.error("Transaction signing error:", error);
  });
