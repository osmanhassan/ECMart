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
function updateDMByID(params, callback) {
  // console.log(params);
  var sql = "UPDATE orders SET DELIVERMAN_ID=? WHERE ID=?";
  db.execute(sql, [params.dmId, params.id], function (flag) {
    callback(flag);
  });
}

function getUnassignedDMOrders(callback) {
  var sql =
    "select users.USER_NAME as BUYER_NAME, users.PHONE as BUYER_PHONE, x.* from users INNER JOIN (SELECT orders.id as ORDER_ID, max(orders.ORDER_PK) as ORDER_ADDRESS,max(orders.BUYER_ID) BUYER_ID, max(orders.BUYER_ADDRESS) as BUYER_ADDRESS,GROUP_CONCAT(users.USER_NAME SEPARATOR '||') as SELLERS, GROUP_CONCAT(users.SHOP_NAME SEPARATOR '||') as SELLERS_SHOP,GROUP_CONCAT(users.PHONE SEPARATOR '||') as SELLERS_PHONE FROM orders inner JOIN order_items on orders.ID = order_items.ORDER_ID INNER JOIN users on order_items.SELLER_ID = users.id WHERE orders.DELIVERMAN_ID is null and orders.ORDER_PK is not null GROUP BY orders.id) x on users.ID = x.BUYER_ID";
  db.getResult(sql, [], function (result) {
    callback(result);
  });
}

module.exports = {
  placeOrder,
  updateOrderChainAddressByID,
  getUnassignedDMOrders,
  updateDMByID,
};
