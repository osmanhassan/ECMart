var db = require("./db");

function insertProduct(params, callback) {
  var sql = "INSERT INTO products VALUES(null, ?, ?, ?, ?, ?, null, ?)";
  db.execute(
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
      if (result) {
        callback(true);
      } else {
        callback(false);
      }
    }
  );
}

function getProductListbyId(uid, callback) {
  var sql = "SELECT * FROM products WHERE SELLER_ID = ?";
  db.getResult(sql, [uid], function (result) {
    callback(result);
  });
}

module.exports = {
  insertProduct,
  getProductListbyId,
};
