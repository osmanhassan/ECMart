const { ethers } = require("ethers");
var user = require("../models/user");
var abiUtil = require("../utils/AbiUtils");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.CHAIN_PROVIDER_URL
);
const ecMartContractAddress = process.env.ECMART_CONTRACT_ADDRESS;
const registrationAbi = abiUtil.getFacetAbi(
  process.env.CHAIN_DIAMOND_CONTRACT_NAME,
  process.env.CHAIN_REGISTRATION_FACET_NAME
);
const contract = new ethers.Contract(
  ecMartContractAddress,
  registrationAbi,
  provider
);

const eventName = "registered"; // Replace with your event name

try {
  console.log("listening");
  contract.on(eventName, (registrationAddress, dbID) => {
    console.log(dbID);
    console.log("Event data:", registrationAddress, " ", dbID.toNumber()); // Access event data here
    var values = {
      address: registrationAddress,
      id: dbID.toNumber(),
    };
    //   signUpRequest.validate(values, function (data) {
    //     if (data.status) {
    user.updateUserChainAddressByID(values, function (status) {
      if (status) {
        console.log(
          "updated address of BUYER/SELLER/DM " +
            values.id +
            " to " +
            values.address
        );
      } else console.log("REgistration address update on Database is failed");
    });
  });
} catch (error) {
  console.error("Event error:", error);
}
