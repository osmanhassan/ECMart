let express = require("express");
let product = require("../models/products");
let router = express.Router();

router.get("/dashboard/", (req, res) => {
  let username = req.session.user.userName;
  res.render("seller_dashboard", { username });
});

router.get("/productAdd/", (req, res) => {
  res.render("seller_productAdd");
});

router.post("/productAdd/", (req, res) => {
  console.log(req.body);
  let sellerId = req.session.user.uid;

  let productDetails = {
    productName: req.body.productName,
    sellerId: sellerId,
    stock: req.body.stock,
    price: req.body.price,
    variant: req.body.variant,
    image: req.body.image,
  };

  product.insertProduct(productDetails, (id) => {
    if (id) {
      productDetails.id = id;
      res.json({ code: 200, status: "failed", data:productDetails });
    } else {
      res.json({ code: 300, status: "failed" });
    }
  });
});

router.get("/productList/", (req, res) => {
  let sellerId = req.session.user.uid;
  product.getProductListbyId(sellerId, (result) => {
    res.render("seller_productList", { products: result });
  });
});
module.exports = router;
