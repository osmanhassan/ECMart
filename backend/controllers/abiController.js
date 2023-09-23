let express = require("express");
let product = require("../models/products");
var abiUtil = require("../utils/AbiUtils");
let router = express.Router();

router.get("/get/facetAbi/:facetID/", (req, res) => {
  let facetName = req.params.facetID;
  res.json(
    abiUtil.getFacetAbi(process.env.CHAIN_DIAMOND_CONTRACT_NAME, facetName)
  );
});

router.get("/get/contractAbi/:contractID/", (req, res) => {
  let contractName = req.params.contractID;
  res.json(abiUtil.getTheAbi(contractName));
});

module.exports = router;
