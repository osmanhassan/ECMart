const express = require("express");
var bodyParser = require("body-parser");
var expressSession = require("express-session");

var signUp = require("./controllers/signupController");
var login = require("./controllers/loginController");

const app = express();

// CONFIGURATION
app.set("view engine", "ejs");
const port = 3000;

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

app.use("/signup", signUp);
app.use("/login", login);

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
