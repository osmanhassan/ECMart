const { ethers } = require("ethers");
const provider = new ethers.providers.JsonRpcProvider(
  process.env.CHAIN_PROVIDER_URL
);
const ecMartContractAddress = process.env.ECMART_CONTRACT_ADDRESS;
const registrationAbi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "orderAddress",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "dbID",
        type: "uint256",
      },
    ],
    name: "sellerRegistered",
    type: "event",
  },
  {
    inputs: [],
    name: "registerBuyer",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "registerDeliveryMan",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "dbID",
        type: "uint256",
      },
    ],
    name: "registerSeller",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];
const contract = new ethers.Contract(
  ecMartContractAddress,
  registrationAbi,
  provider
);

const eventName = "sellerRegistered"; // Replace with your event name

try {
  console.log("listening");
  contract.on(eventName, (address, dbID) => {
    console.log("Event data:", address, " ", dbID.toNumber()); // Access event data here
  });
} catch (error) {
  console.error("Event error:", error);
}
