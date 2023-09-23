const { ethers } = require("ethers");
var order = require("../models/orders");
var abiUtil = require("../utils/AbiUtils");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.CHAIN_PROVIDER_URL
);
const ecMartContractAddress = process.env.ECMART_CONTRACT_ADDRESS;
const orderAbi = abiUtil.getFacetAbi(
  process.env.CHAIN_DIAMOND_CONTRACT_NAME,
  process.env.CHAIN_ORDER_FACET_NAME
);
const contract = new ethers.Contract(ecMartContractAddress, orderAbi, provider);

const eventName = "Save"; // Replace with your event name

try {
  console.log("listening for new Order of chain");
  contract.on(eventName, (address, dbID) => {
    console.log();
    order.updateOrderChainAddressByID(
      { address: address, id: dbID.toNumber() },
      function (status) {
        if (status) {
          console.log("addres of order " + dbID + " is " + address);
        } else {
          console.log("order public key update failed");
        }
      }
    );
    // Access event data here
    //  var values = {
    //    final_price: _finalPrice.toString(),
    //    address: address,
    //    id: dbID.toNumber(),
    //  };
    //  //   signUpRequest.validate(values, function (data) {
    //  //     if (data.status) {
    //  product.updateProductChainAddressByID(values, function (status) {
    //    if (status) {
    //      console.log(
    //        "updated address of product " +
    //          values.id +
    //          " to " +
    //          values.address +
    //          " with final Price " +
    //          values.final_price
    //      );
    //    } else console.log("address update failed");
    //  });
  });
} catch (error) {
  console.error("Event error:", error);
}
