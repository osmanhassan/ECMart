const { ethers } = require("ethers");
var product = require("../models/products");
var abiUtil = require("../utils/AbiUtils");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.CHAIN_PROVIDER_URL
);
const ecMartContractAddress = process.env.ECMART_CONTRACT_ADDRESS;
const productAbi = abiUtil.getFacetAbi(
  process.env.CHAIN_DIAMOND_CONTRACT_NAME,
  process.env.CHAIN_PRODUCT_FACET_NAME
);
const contract = new ethers.Contract(
  ecMartContractAddress,
  productAbi,
  provider
);

const eventName = "productSaved"; // Replace with your event name

try {
  console.log("listening for new Product of chain");
  contract.on(eventName, (_finalPrice, address, dbID) => {
    console.log(
      "Product data: ",
      _finalPrice.toString(),
      "  ",
      address,
      " ",
      dbID.toNumber()
    ); // Access event data here
    var values = {
      final_price: _finalPrice.toString(),
      address: address,
      id: dbID.toNumber(),
    };
    //   signUpRequest.validate(values, function (data) {
    //     if (data.status) {
    product.updateProductChainAddressByID(values, function (status) {
      if (status) {
        console.log(
          "updated address of product " +
            values.id +
            " to " +
            values.address +
            " with final Price " +
            values.final_price
        );
      } else console.log("address update failed");
    });
  });
} catch (error) {
  console.error("Event error:", error);
}
