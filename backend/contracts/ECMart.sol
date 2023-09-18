// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// // Uncomment this line to use console.log
// import "hardhat/console.sol";
// import "./Product.sol";
// import "./Order.sol";

// contract ECMart {
//     uint256 private deliveryManChargePerSeller = 3;
//     uint256 private deliveryManChargePerUnit = 3;

//     address ECMART_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
//     address REVIEW_RATING_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

//     mapping(address => Order) public orders;
//     mapping(address => Product) public products;
//     mapping(address => uint256) public sellers;
//     mapping(address => uint256) public buyers;
//     mapping(address => uint256) public deliveryMen;
//     mapping(address => uint256) public tempSellerAmountMapping;

//     // mapping(address => uint256) public addressToAmountFunded;

//     // Orders

//     // // amount calculation
//     function calculateOrderAmount(
//         address[] calldata _orderItems,
//         uint256[] calldata _units
//     ) private view returns (uint256, uint256[] memory, uint256[] memory) {
//         require(
//             _orderItems.length == _units.length,
//             "Arrays must have the same length"
//         );

//         uint256 orderTotalSellerPayable = 0;
//         uint256 orderTotalDeliveryManPayable = 0;
//         uint256 orderTotalEcMartPayable = 0;
//         uint256 orderTotalReviewRatingPayable = 0;
//         uint256 TOTAL_PAYABLE = 0;
//         //check what happens
//         uint256[] memory orderUnitPrice = new uint256[](_orderItems.length);
//         uint256[] memory orderUnitFinalPrice = new uint256[](
//             _orderItems.length
//         );

//         for (uint256 i = 0; i < _orderItems.length; i++) {
//             address productAddress = _orderItems[i];
//             Product product = products[productAddress];
//             uint256 unit = _units[i];

//             require(address(product) != address(0), "Product doesn't exist");
//             require(
//                 product.getQuantity() >= unit,
//                 "Product inventory is not Sufficient"
//             );

//             orderUnitPrice[i] = product.getPrice();
//             orderUnitFinalPrice[i] = product.getProductFinalPrice();

//             orderTotalSellerPayable += product.getPrice() * unit;
//             orderTotalDeliveryManPayable += deliveryManChargePerUnit * unit;
//             orderTotalEcMartPayable += product.getEcmartAmount() * unit;
//             // **** REview Rating is not unit specific
//             orderTotalReviewRatingPayable += product.getReviewRatingAmount();
//         }
//         TOTAL_PAYABLE =
//             orderTotalSellerPayable +
//             orderTotalDeliveryManPayable +
//             orderTotalEcMartPayable +
//             orderTotalReviewRatingPayable;
//         return (TOTAL_PAYABLE, orderUnitPrice, orderUnitFinalPrice);
//     }

//     function placeOrder(
//         address[] calldata _orderItems,
//         uint256[] calldata _units
//     ) public payable {
//         (
//             uint256 TOTAL_PAYABLE,
//             uint256[] memory orderUnitPrice,
//             uint256[] memory orderUnitFinalPrice
//         ) = calculateOrderAmount(_orderItems, _units);

//         // hold money starts

//         //****  need implement getConversionRate() method
//         require(msg.value >= TOTAL_PAYABLE, "You need to spend more ETH!");

//         // hold money ends

//         // Create orders starts

//         Order order = new Order(
//             msg.sender,
//             _orderItems,
//             _units,
//             address(this),
//             TOTAL_PAYABLE,
//             orderUnitPrice,
//             orderUnitFinalPrice
//         );
//         orders[address(order)] = order;

//         // Create orders ends

//         // Product Quantity update starts
//         for (uint256 i = 0; i < _orderItems.length; i++) {
//             address productAddress = _orderItems[i];
//             Product product = products[productAddress];
//             uint256 unit = _units[i];
//             product.updateQuantity(product.getQuantity() - unit);
//         }
//         // Product Quantity update ends
//     }

//     function setDeliveryMan(
//         address orderAddress,
//         address deliveryManAddress
//     ) public {
//         Order order = orders[orderAddress];
//         // deliveryMen[deliveryManAddress] != address(0) , wrong logic
//         require(deliveryMen[deliveryManAddress] != 0, "Invalid delivery man");
//         require(address(order) != address(0), "Invalid order");
//         require(
//             order.getDeliveryMan() == address(0),
//             "Delivery man is already set"
//         );

//         order.setDeliveryMan(deliveryManAddress);
//     }

//     function setDelivery(
//         address orderAddress,
//         address[] memory _deliveryItems,
//         uint256[] memory _deliveryUnits
//     ) public {
//         Order order = orders[orderAddress];
//         require(
//             _deliveryItems.length == _deliveryUnits.length,
//             "Arrays must have the same length"
//         );
//         require(address(order) != address(0), "Invalid order");
//         require(order.getDeliveryMan() == msg.sender, "Invalid delivery man");
//         require(order.getIsDelivered() == false, "already delivered");

//         order.setDelivery(_deliveryItems, _deliveryUnits);
//     }

//     function payOrder(address orderAddress) public {
//         Order order = orders[orderAddress];

//         require(address(order) != address(0), "Invalid order");
//         require(order.getIsDelivered() == false, "Already Paid");
//         require(
//             msg.sender == order.getBuyer(),
//             "Only the buyer can pay the bill"
//         );
//         address[] memory deliveredItems = order.getDeliveredItems();
//         uint256[] memory deliveredUnits = order.getDeliveredUnits();

//         // send to seller  --> Only for Delivered Goods

//         uint256 sellersPaid = 0;
//         uint256 deliveryManPaid = 0;
//         uint256 ecMartPaid = 0;
//         uint256 reviewRatingPaid = 0;
//         for (uint256 i = 0; i < deliveredItems.length; i++) {
//             address productAddress = deliveredItems[i];
//             Product product = products[productAddress];
//             uint256 unitPrice = order.getProductWiseUnitPrice(productAddress);
//             uint256 units = deliveredUnits[i];

//             deliveryManPaid += units * deliveryManChargePerUnit;
//             ecMartPaid += units * product.getEcmartAmount();
//             reviewRatingPaid += product.getReviewRatingAmount();

//             uint256 sellerPayable = units * unitPrice;

//             (bool callSuccess, ) = payable(product.getSeller()).call{
//                 value: sellerPayable
//             }("");

//             require(callSuccess, "Call failed");

//             sellersPaid += sellerPayable;
//         }

//         //

//         // send to delivery man

//         (bool callSuccessDeliveryMan, ) = payable(order.getDeliveryMan()).call{
//             value: deliveryManPaid
//         }("");

//         require(callSuccessDeliveryMan, "Call failed");

//         //

//         // send to ecMart
//         (bool callSuccessEcMart, ) = payable(ECMART_ADDRESS).call{
//             value: ecMartPaid
//         }("");

//         require(callSuccessEcMart, "Call failed");
//         //

//         // send to review rating
//         (bool callSuccessReviewRating, ) = payable(REVIEW_RATING_ADDRESS).call{
//             value: reviewRatingPaid
//         }("");

//         require(callSuccessReviewRating, "Call failed");
//         //

//         // set delivered status
//         order.setIsDelivered(true);
//         //

//         // refund buyer
//         uint256 refundable = order.getBuyerTotalPaid() -
//             (sellersPaid + deliveryManPaid + ecMartPaid + reviewRatingPaid);
//         (bool callSuccessRefund, ) = payable(order.getBuyer()).call{
//             value: refundable
//         }("");

//         require(callSuccessRefund, "Call failed");
//         //

//         // set refund amount staus
//         order.setIsRefunded(true);
//         order.setRefundedAmount(refundable);
//         //
//     }

//     function refund(address orderAddress) public {}

//     //

//     //Products

//     function addProduct(
//         string memory _name,
//         uint256 _price,
//         string memory _description,
//         uint256 _quantity
//     ) public {
//         require(sellers[msg.sender] == 1, "You are not a seller");
//         Product product = new Product(
//             _name,
//             _price,
//             _description,
//             _quantity,
//             msg.sender,
//             address(this)
//         );
//         products[address(product)] = product;
//     }

//     // methods for product update and delete

//     //

//     //  seller

//     function registerSeller() public {
//         // need to add admin access control
//         sellers[msg.sender] = 1;
//     }

//     //

//     // buyer

//     function registerBuyer() public {
//         buyers[msg.sender] = 2;
//     }

//     //

//     // deliveryMen

//     function registerDeliveryMan() public {
//         // need to add admin access control
//         deliveryMen[msg.sender] = 3;
//     }

//     //
// }
