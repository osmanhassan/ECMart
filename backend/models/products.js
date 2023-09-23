var db = require("./db");

function insertProduct(params, callback) {
  var sql =
    "INSERT INTO products VALUES(null, ?, ?, ?, ?, null, ?, null, ?,null)";
  db.executeGetId(
    sql,
    [
      params.productName,
      params.sellerId,
      params.stock,
      params.price,
      params.variant,
      params.image,
    ],
    function (result) {
      if (result != -1) {
        callback(result);
      } else {
        callback(undefined);
      }
    }
  );
}

function getProductbyId(productId, callback) {
  var sql = "SELECT * FROM products WHERE ID = ?";
  db.getResult(sql, [productId], function (result) {
    callback(result);
  });
}

function getProductListbyId(uid, callback) {
  var sql = "SELECT * FROM products WHERE SELLER_ID = ?";
  db.getResult(sql, [uid], function (result) {
    callback(result);
  });
}

function getAllProducts(callback) {
  let sql = "SELECT * FROM products";
  db.getResult(sql, null, function (result) {
    callback(result);
  });
}

function updateProductChainAddressByID(params, callback) {
  var sql = "UPDATE products SET FINAL_PRICE=?, ADDRESS=? WHERE ID=?";
  db.execute(
    sql,
    [params.final_price, params.address, params.id],
    function (flag) {
      callback(flag);
    }
  );
}

module.exports = {
  insertProduct,
  getProductbyId,
  getProductListbyId,
  getAllProducts,
  updateProductChainAddressByID,
};
