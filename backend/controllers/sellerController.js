let express = require("express");
let product = require("../models/products");
const multer = require("multer");
const router = express.Router();

// Configure multer to specify where to store uploaded images
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "./public/images/DB_images/"); // Store uploaded images in the 'uploads' directory
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname); // Rename the file with a unique name
  },
});

const upload = multer({ storage });

router.get("/dashboard/", (req, res) => {
  let username = req.session.user.userName;
  res.render("seller_dashboard", { username });
});

router.get("/productAdd/", (req, res) => {
  res.render("seller_productAdd");
});

router.post("/productAdd/", upload.single("image"), (req, res) => {
  console.log(req.body);
  let imagePath = req.file.path;
  imagePath = imagePath.slice(6);

  let sellerId = req.session.user.uid;

  let productDetails = {
    productName: req.body.productName,
    sellerId: sellerId,
    stock: req.body.stock,
    price: req.body.price,
    variant: req.body.variant,
    image: imagePath,
  };

  product.insertProduct(productDetails, (id) => {
    if (id) {
      productDetails.id = id;
      res.json({ code: 200, status: "failed", data: productDetails });
    } else {
      res.json({ code: 300, status: "failed" });
    }
  });
});

router.get("/productList/", (req, res) => {
  let sellerId = req.session.user.uid;
  product.getProductListbyId(sellerId, (result) => {
    res.render("seller_productList", { products: result });
  });
});
module.exports = router;
