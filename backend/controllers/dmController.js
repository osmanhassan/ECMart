var express = require("express");
var router = express.Router();
let orders = require("../models/orders");

router.get("/dashboard/", (req, res) => {
  res.render("dm_dashboard");
});

router.get("/orderCollect/", (req, res) => {
  orders.getUnassignedDMOrders(function (result) {
    res.render("dm_order_collect", { orders: result, uid: req.session.user.uid });
  });
});

router.get("/orderDelivery/", (req, res) => {
  res.render("dm_order_delivery");
});

router.get("/orderComplete/", (req, res) => {
  res.render("dm_order_complete");
});

module.exports = router;
