var express = require("express");
var user = require("../models/user");
const session = require("express-session");
var router = express.Router();

router.get("/", function (request, response) {
  response.render("login", { userName: "", error: "" });
});

router.post("/", function (request, response) {
  user.getUserByNamePass(request.body, function (result) {
    if (result.length > 0 && result[0].PASSWORD == request.body.password) {
      // result[0].activity = "online";
      var data = {
        uid: result[0].ID,
        userName: result[0].USER_NAME,
        password: result[0].PASSWORD,
        role: result[0].ROLE,
        email: result[0].EMAIL,
        phone: result[0].PHONE,
        shopName: result[0].SHOP_NAME,
        nid: result[0].NID,
      };

      request.session.user = data;
      console.log(request.session.user.userName + " logged in");
      if (request.session.user.role == 1) {
        response.redirect("/seller/dashboard/");
      } else if (request.session.user.role == 2) {
        response.redirect("/buyer/productList/");
      } else {
        response.redirect("/deliveryman/dashboard/");
      }
    } else {
      console.log(result);
      console.log(request.body.password);
      response.render("login", {
        userName: request.body.userName,
        error: "Invalid userName or password",
      });
    }
  });
});

module.exports = router;
