const Web3 = require('web3');
const contractJson = require('./YourContract.json'); // Replace with your contract's JSON artifact

function deployContract() {
    const web3 = new Web3(window.ethereum);

    const contract = new web3.eth.Contract(contractJson.abi);

    web3.eth.getCoinbase((error, coinbase) => {
        if (error) {
            console.error('Error fetching user address:', error);
            return;
        }

        contract.deploy({
            data: contractJson.bytecode,
            arguments: [arg1, arg2, ...], // Provide constructor arguments
        }).send({
            from: coinbase, // Use the user's Ethereum address
            gas: 2000000, // Adjust the gas limit as needed
        })
        .on('error', error => {
            console.error('Error deploying contract:', error);
        })
        .on('transactionHash', transactionHash => {
            console.log('Transaction hash:', transactionHash);
        })
        .on('receipt', receipt => {
            console.log('Contract deployed at address:', receipt.contractAddress);
        });
    });
}

// Call the function to deploy the contract
deployContract();


const Web3 = require('web3');
const contractAbi = ...; // ABI of your smart contract
const contractAddress = '0x...'; // Address of your smart contract
const web3 = new Web3(window.ethereum);

function sendEtherToContract(amountInWei) {
    web3.eth.getCoinbase((error, sender) => {
        if (error) {
            console.error('Error fetching user address:', error);
            return;
        }

        web3.eth.getGasPrice((error, gasPrice) => {
            if (error) {
                console.error('Error fetching gas price:', error);
                return;
            }

            const contract = new web3.eth.Contract(contractAbi, contractAddress);

            contract.methods
                .yourPayableFunction() // Replace with the name of your payable function
                .send({
                    from: sender,
                    to: contractAddress,
                    value: amountInWei,
                    gasPrice: gasPrice,
                })
                .on('transactionHash', transactionHash => {
                    console.log('Transaction hash:', transactionHash);
                })
                .on('receipt', receipt => {
                    console.log('Transaction receipt:', receipt);
                })
                .on('error', error => {
                    console.error('Error sending transaction:', error);
                });
        });
    });
}

// Example: Sending 0.1 Ether (in Wei) to the contract
sendEtherToContract(web3.utils.toWei('0.1', 'ether'));

