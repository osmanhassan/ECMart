let express = require("express");
let router = express.Router();
let product = require("../models/products");

router.get("/productList", (req, res) => {
  product.getAllProducts((result) => {
    console.log(result);
    res.render("buyer_productList", { products: result });
  });
});

module.exports = router;
