let express = require("express");
let router = express.Router();
let product = require("../models/products");
let orders = require("../models/orders");
let user = require("../models/user");

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

router.post("/addToCart/", (req, res) => {
  console.log(req.body);
  const productId = req.body.id;
  const unitPrice = req.body.unitPrice;
  const name = req.body.name;

  if (req.session.cart == undefined) {
    req.session.cart = {};
  }
  user.findById(req.body.sellerId, function (result) {
    if (result.length > 0) {
      req.session.cart[productId] = {
        name: name,
        quantity: req.body.quantity,
        unit_price: unitPrice,
        sellerId: req.body.sellerId,
        productPk: req.body.productPk,
        sellerAddress: result[0].ADDRESS,
      };
      console.log(req.session.cart);
      res.redirect("/buyer/productList/");
    } else {
      res.redirect("/buyer/productList/");
    }
  });
});

router.get("/buyer_cart/", (req, res) => {
  console.log(req.session.cart);
  res.render("buyer_cart", { cart: req.session.cart });
});

router.get("/order/", (req, res) => {
  // console.log("oder----------------------");
  var cart = req.session.cart;
  var productId = [];
  var sellerID = [];
  var sellerAddress = [];
  var units = [];
  var unitPrice = [];
  var itemTotal = [];
  var productPk = [];
  var total = 0;
  for (var x in cart) {
    productId.push(x);
    sellerID.push(cart[x].sellerId);
    sellerAddress.push(cart[x].sellerAddress);
    units.push(cart[x].quantity);
    unitPrice.push(cart[x].unit_price);
    productPk.push(cart[x].productPk);
    var itemTotalam = cart[x].quantity * cart[x].unit_price;
    itemTotal.push(itemTotalam);
    total += itemTotalam;
  }
  console.log(req.session.user);
  let orderInfo = {
    // 1st query
    // orderId: autoDB,
    buyerID: req.session.user.uid,
    buyerAddress: req.session.user.address,
    total: total,

    // 2nd query
    // orderItemsID: autoDB,
    // orderID : fromDB_after_1st_query_execution,
    productId: productId,
    sellerID: sellerID,
    sellerAddress: sellerAddress,
    units: units,
    unitPrice: unitPrice,
    itemTotal: itemTotal,
    productPk: productPk,
    // 3rd query
    // otpId: autoDB,
    // orderId: fromDB_after_1st_query_execution,
    // sellerId : givenPreviously,
  };

  orders.placeOrder(orderInfo, (order_id) => {
    if (order_id != -1) {
      orderInfo.order_id = order_id;
      req.session.cart = undefined;
      res.json({ code: 200, status: "success", data: orderInfo });
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
