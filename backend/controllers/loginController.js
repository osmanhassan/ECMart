var express = require("express");
var user = require("../models/user");
var router = express.Router();

router.get("/", function (request, response) {
  response.render("login", { userName: "", error: "" });
});

router.post("/", function (request, response) {
  user.getUserByNamePass(request.body, function (result) {
    if (result.length > 0 && result[0].PASSWORD == request.body.password) {
      result[0].activity = "online";
      var data = {
        uid: result[0].ID,
        name: result[0].USER_NAME,
        password: result[0].PASSWORD,
        role: result[0].ROLE,
        email: result[0].EMAIL,
        phone: result[0].PHONE,
        email: result[0].SHOP_NAME,
        email: result[0].NID,
      };

      request.session.user = data;
      console.log(request.session.user.name + " logged in");
      response.redirect("/profile");
    } else {
      console.log(result);
      console.log(request.body.password);
      response.render("login", {
        userName: request.body.userName,
        error: "Invalid username or password",
      });
    }
  });
});

module.exports = router;
