let db = require("./db");

function placeOrder(params, callback) {
  let order_id;
  let no_of_products = params.productId.length;

  let sql_orders = "INSERT INTO orders VALUES (null, ?, ?, ?, null, null)";
  let sql_orderItems = "INSERT INTO order_items VALUES ";
  let sql_otps =
    "INSERT into otps (SELLER_ID, ORDER_ID) SELECT DISTINCT SELLER_ID, ? as ORDER_ID from order_items WHERE ORDER_ID = ?";

  //1st query
  db.executeGetId(
    sql_orders,
    [params.buyerID, params.buyerAddress, params.total],
    function (result) {
      if (result == -1) {
        console.log("error at 1st query of order place");
        callback(false);
      } else {
        order_id = result;
        let i = 0;
        // 2nd query
        var orderItemValuesQuery = [];
        var orderItemValues = [];
        for (i = 0; i < no_of_products; i++) {
          orderItemValuesQuery.push("(null, ?, ?, ?, ?, ?, ?, ?)");
          orderItemValues.push(order_id);
          orderItemValues.push(params.productId[i]);
          orderItemValues.push(params.sellerID[i]);
          orderItemValues.push(params.sellerAddress[i]);
          orderItemValues.push(params.units[i]);
          orderItemValues.push(params.unitPrice[i]);
          orderItemValues.push(params.itemTotal[i]);
        }
        sql_orderItems += orderItemValuesQuery.join(", ");
        console.log(sql_orderItems);
        db.execute(sql_orderItems, orderItemValues, function (result) {
          if (result) {
            db.execute(sql_otps, [order_id, order_id], function (status) {
              if (status) {
                callback(order_id);
              } else {
                callback(-1);
                console.log("Error in 3rd query");
              }
            });
          } else {
            console.log("error at 2nd query of order place");
            callback(-1);
          }
        });
      }
    }
  );
}

function updateOrderChainAddressByID(params, callback) {
  // console.log(params);
  var sql = "UPDATE orders SET ORDER_PK=? WHERE ID=?";
  db.execute(sql, [params.address, params.id], function (flag) {
    callback(flag);
  });
}

module.exports = {
  placeOrder,
  updateOrderChainAddressByID,
};
