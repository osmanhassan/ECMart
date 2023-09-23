const { ethers } = require("ethers");
var order = require("../models/orders");
var abiUtil = require("../utils/AbiUtils");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.CHAIN_PROVIDER_URL
);
const ecMartContractAddress = process.env.ECMART_CONTRACT_ADDRESS;
const orderAbi = abiUtil.getFacetAbi(
  process.env.CHAIN_DIAMOND_CONTRACT_NAME,
  process.env.CHAIN_DELIVERY_FACET_NAME
);
const contract = new ethers.Contract(ecMartContractAddress, orderAbi, provider);

const eventName = "deliveryManSet"; // Replace with your event name

try {
  console.log("listening for deliveryman to set in order");
  contract.on(eventName, (orderdbID, dmdbID) => {
    console.log();
    order.updateDMByID(
      { id: orderdbID.toNumber(), dmId: dmdbID.toNumber() },
      function (status) {
        if (status) {
          console.log("deliveryman " + dmdbID + " is set to order " + orderdbID);
        } else {
          console.log("deliveryman " + dmdbID + " is set to order " + orderdbID + "failed");
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
