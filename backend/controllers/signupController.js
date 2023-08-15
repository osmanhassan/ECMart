var express = require("express");
// var signUpRequest = require('../requests/signUpRequest');
var user = require("../models/user");
var router = express.Router();

router.get("/", function (request, response) {
  data = {
    userName: "",
    role: "",
    email: "",
    phone: "",
    shopName: "",
  };
  response.render("signup", data);
  // response.json(data);
});

router.post("/", function (request, response) {
  // console.log(request.body);
  // params.userName,

  var values = {
    userName: request.body.username,
    password: request.body.password,
    role: 1,
    email: request.body.email,
    phone: request.body.phone,
    shopName: request.body.shopName,
    nid: request.body.nid,
  };
  //   signUpRequest.validate(values, function (data) {
  //     if (data.status) {
  user.insert(values, function (status) {
    if (status) {
      response.redirect("/signup/");
    } else response.json({ code: 300, status: "failed" });
  });
  //  } else response.render("signUp", data);
});

// router.post("/seachusername", function (request, response) {
//   var userName = request.body.name;
//   user.findByName(userName, function (result) {
//     if (result.length == 0) response.send("");
//     else response.send(userName + " is already taken try with another one.");
//   });
// });

module.exports = router;
