var express = require("express");
// var signUpRequest = require('../requests/signUpRequest');
var user = require("../models/user");
var router = express.Router();

// SignUP Page for all
router.get("/", function (request, response) {
  response.render("signup");
  // response.json(data);
});

// SELLER SIGNUP VIEW
router.get("/seller/", function (request, response) {
  data = {
    userName: "",
    role: "",
    email: "",
    phone: "",
    shopName: "",
  };
  response.render("signup_seller", data);
  // response.json(data);
});

// SELLER SIGN-UP on DB
router.post("/seller/", function (request, response) {
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
    address: request.body.address,
  };
  //   signUpRequest.validate(values, function (data) {
  //     if (data.status) {
  user.insertSeller(values, function (id) {
    if (id) {
      values.id = id;
      // response.redirect("/login/");
      response.json({ code: 200, status: "suceess", data: values });
    } else response.json({ code: 300, status: "failed" });
  });
  //  } else response.render("signUp", data);
});

// BUYER SIGN-UP VIEW
// how does it knows `signup_buyer` ????
router.get("/buyer/", (request, response) => {
  data = {
    userName: "",
    role: "",
    email: "",
    phone: "",
  };
  response.render("signup_buyer", data);
});

// BUYER SIGN-UP on DB
router.post("/buyer/", function (request, response) {
  var values = {
    userName: request.body.username,
    password: request.body.password,
    role: 2,
    email: request.body.email,
    phone: request.body.phone,
    address: request.body.address,
    // later provide null
    // shopName: request.body.shopName,
    // nid: request.body.nid,
  };
  //   signUpRequest.validate(values, function (data) {
  //     if (data.status) {
  user.insertBuyer(values, function (id) {
    if (id) {
      values.id = id;
      response.json({ code: 200, status: "suceess", data: values });
    } else response.json({ code: 300, status: "failed" });
  });
  //  } else response.render("signUp", data);
});

//Delivery-man SIGN UP VIEW
router.get("/deliveryman/", (request, response) => {
  data = {
    userName: "",
    role: "",
    email: "",
    phone: "",
    nid: "",
  };
  response.render("signup_deliveryman", data);
});

// Delivery-man SIGN-UP on DB
router.post("/deliveryman/", function (request, response) {
  var values = {
    userName: request.body.username,
    password: request.body.password,
    role: 3,
    email: request.body.email,
    phone: request.body.phone,
    nid: request.body.nid,
    address: request.body.address,
  };
  //   signUpRequest.validate(values, function (data) {
  //     if (data.status) {
  user.insertDM(values, function (id) {
    if (id) {
      values.id = id;
      response.json({ code: 200, status: "suceess", data: values });
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
