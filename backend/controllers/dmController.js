var express = require("express");
var router = express.Router();
let orders = require("../models/orders");

router.get("/dashboard/", (req, res) => {
  res.render("dm_dashboard");
});

router.get("/orderCollect/", (req, res) => {
  orders.getUnassignedDMOrders(function (result) {
    res.render("dm_order_collect", {
      orders: result,
      uid: req.session.user.uid,
    });
  });
});

router.get("/orderDelivery/", (req, res) => {
  orders.getByDeliveryManandStatus(
    [req.session.user.uid, 1],
    function (result) {
      console.log(result);
      res.render("dm_order_delivery", {
        orders: result,
        uid: req.session.user.uid,
      });
    }
  );
});

router.post("/orderDelivery/", (req, res) => {
  var data = JSON.parse(req.body.data);
  console.log("aasdadasdasdasdasd");
  console.log(data);
  orders.deleteDeliveryDetailsByOrderID(data, function (status) {
    if (status) {
      orders.setDelivery(data, data.orderId, function (status) {
        if (status) {
          res.json({ code: 200 });
        } else {
          res.json({ code: 300 });
        }
      });
    } else {
      res.json({ code: 300 });
    }
  });
});

router.get("/orderComplete/", (req, res) => {
  res.render("dm_order_complete");
});

module.exports = router;
