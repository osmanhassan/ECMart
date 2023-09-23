var express = require("express");
var router = express.Router();

router.get("/dashboard/", (req, res) => {
  res.render("dm_dashboard");
});

router.get("/orderCollect/", (req, res) => {
  res.render("dm_order_collect");
});

router.get("/orderDelivery/", (req, res) => {
  res.render("dm_order_delivery");
});

router.get("/orderComplete/", (req, res) => {
  res.render("dm_order_complete");
});

module.exports = router;
