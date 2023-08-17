let db = require("./db");

function placeOrder(params, callback) {
  let order_id;
  let no_of_products = params.productId.length;

  let sql_orders = "INSERT INTO orders VALUES (null, ?, ?, ?, ?)";
  let sql_orderItems = "INSERT INTO order_items VALUES ";
  let sql_otps =
    "INSERT into otps (SELLER_ID, ORDER_ID) SELECT DISTINCT SELLER_ID, ? as ORDER_ID from order_items WHERE ORDER_ID = ?";

  //1st query
  db.executeGetId(
    sql_orders,
    [params.buyerID, params.buyerAddress, params.total, params.deliverymanID],
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
                callback(status);
              } else {
                callback(status);
                console.log("Error in 3rd query");
              }
            });
          } else {
            console.log("error at 2nd query of order place");
            callback(false);
          }
        });
      }
    }
  );
}

module.exports = {
  placeOrder,
};
