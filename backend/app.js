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

app.use("/css", express.static(__dirname + "/public/css"));
app.use("/images", express.static(__dirname + "/public/images"));
app.use("/js", express.static(__dirname + "/public/js"));

app.use("/signup", signUp);
app.use("/login", login);

// app.get("/", (req, res) => {
//   res.send("Hello World!");
// });

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
