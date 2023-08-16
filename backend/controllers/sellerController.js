let express = require("express");
let product = require("../models/products");
let router = express.Router();

router.get("/dashboard", (req, res) => {
  res.render("seller_dashboard");
});

router.get("/productAdd", (req, res) => {
  res.render("seller_productAdd");
});

router.post("/productAdd", (req, res) => {
  console.log(req.body);
  let productDetails = {
    productName: req.body.productName,
    sellerId: 6,
    stock: req.body.stock,
    price: req.body.price,
    variant: req.body.variant,
    image: req.body.image,
  };

  product.insertProduct(productDetails, (status) => {
    if (status) {
      res.redirect("/seller/dashboard");
    } else {
      response.json({ code: 300, status: "failed" });
    }
  });
});

router.get("/productList", (req, res) => {
  product.getProductListbyId(4, (result) => {
    res.render("seller_productList", { products: result });
  });
});
module.exports = router;
