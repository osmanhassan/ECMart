let express = require("express");
let router = express.Router();
let product = require("../models/products");
let orders = require("../models/orders");

router.get("/productList/", (req, res) => {
  product.getAllProducts((result) => {
    //console.log(result);
    // console.log(result);
    res.render("buyer_productList", { products: result });
  });
});

router.get("/productView/:id/", (req, res) => {
  const productId = req.params.id;
  product.getProductbyId(productId, (result) => {
    console.log(result);
    if (result.length != 0) {
      res.render("buyer_productView", { product: result });
    } else {
      res.json({
        code: 500,
        status: "server-error",
        message: "Product not found",
      });
    }
  });
});

router.get("/buyer_cart/", (req, res) => {
  res.render("buyer_cart");
});

router.get("/order/", (req, res) => {
  // console.log("oder----------------------");
  let orderInfo = {
    // 1st query
    // orderId: autoDB,
    buyerID: 5,
    buyerAddress: "Uttara",
    total: 645,
    deliverymanID: 9,
    // 2nd query
    // orderItemsID: autoDB,
    // orderID : fromDB_after_1st_query_execution,
    productId: [8, 9, 14],
    sellerID: [4, 4, 6],
    sellerAddress: ["Shyamoli", "Shyamoli", "Dhanmondi"],
    units: [3, 1, 1],
    unitPrice: [55, 2100, 750],
    itemTotal: [165, 2100, 750],
    // 3rd query
    // otpId: autoDB,
    // orderId: fromDB_after_1st_query_execution,
    // sellerId : givenPreviously,
  };

  orders.placeOrder(orderInfo, (status) => {
    if (status) {
      res.redirect("/buyer/productList/");
    } else {
      res.json({ code: 500, status: "server-error" });
    }
  });
});

// function randomNumberGenerate() {
//   // generate 6 digit random otp number
//   return Math.floor(Math.random() * Math.pow(10, 6));
// }
module.exports = router;
