const express = require("express");
var bodyParser = require("body-parser");
var expressSession = require("express-session");
const port = 3000;

var signUp = require("./controllers/signupController");
var login = require("./controllers/loginController");
let seller = require("./controllers/sellerController");
let buyer = require("./controllers/buyerController");
let logout = require("./controllers/logoutController");

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
app.use("/css", express.static(__dirname + "/public/css"));
app.use("/images", express.static(__dirname + "/public/images"));
app.use("/js", express.static(__dirname + "/public/js"));

//authentication function

function auth(request, response, next) {
  if (!request.session.user) {
    response.redirect("/login/");
  } else next();
}

//endpoint handler
app.use("/signup", signUp);
app.use("/login", login);
app.use("/logout", logout);
app.use("/seller", auth, seller);
app.use("/buyer", auth, buyer);

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
