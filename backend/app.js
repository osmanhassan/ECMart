require("dotenv").config();
const express = require("express");
var bodyParser = require("body-parser");
var expressSession = require("express-session");
const port = process.env.SERVER_PORT || 3000;

var signUp = require("./controllers/signupController");
var login = require("./controllers/loginController");
let seller = require("./controllers/sellerController");
let buyer = require("./controllers/buyerController");
let logout = require("./controllers/logoutController");
let landing = require("./controllers/landingController");
let abi = require("./controllers/abiController");
let chainRegistrationListener = require("./services/registrationChainService");
let chainProductListener = require("./services/productChainService");
let dm = require("./controllers/dmController");
let orderProductListener = require("./services/orderChainService");


const app = express();

// CONFIGURATION
app.set("view engine", "ejs");

// parse application/x-www-form-urlencoded
app.use(bodyParser.urlencoded({ extended: false }));

app.use(
  expressSession({
    secret: "my top secret password",
    saveUninitialized: true,
    resave: false,
  })
);
// when user_requires/application_requires any CSS/JS/image from the server --> express.static --> The express. static middleware function is used to expose a directory or a file to a particular URL so its contents can be publicly accessed.
app.use("/css", express.static(__dirname + "/public/css")); //__dirname ==> is till ==> ECART/backend
app.use("/images", express.static(__dirname + "/public/images"));
app.use("/js", express.static(__dirname + "/public/js"));

//authentication function

function authentication(request, response, next) {
  if (!request.session.user) {
    response.redirect("/login/");
  } else next();
}

function sellerAuthorization(request, response, next) {
  if (request.session.user.role != 1) {
    response.render("access_denied");
  } else next();
}
function buyerAuthorization(request, response, next) {
  if (request.session.user.role != 2) {
    response.render("access_denied");
  } else next();
}

function dmAuthorization(request, response, next) {
  if (request.session.user.role != 3) {
    response.render("access_denied");
  } else next();
}

//endpoint handler
app.use("", landing);
app.use("/signup", signUp);
app.use("/login", login);
app.use("/abi", abi);
app.use("/logout", logout);
app.use("/seller", authentication, sellerAuthorization, seller);
app.use("/buyer", authentication, buyerAuthorization, buyer);
app.use("/dm", authentication, dmAuthorization, dm);

// chain activity
//  chainRegistrationListener.initRegistrationListener();

//

app.listen(port, () => {
  console.log(`ECMart BackEND app listening on port ${port}`);
});
// dsad
