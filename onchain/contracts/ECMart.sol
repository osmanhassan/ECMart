pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./Product.sol";
import "./Order.sol";

contract ECMart {
    uint256 private deliveryManChargePerSeller = 3;
    uint256 private deliveryManChargePerUnit = 3;

    address ECMART_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address REVIEW_RATING_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    mapping(address => Order) public orders;
    mapping(address => Product) public products;
    mapping(address => uint8) public sellers;
    mapping(address => uint8) public buyers;
    mapping(address => uint8) public deliveryMen;
    mapping(address => uint256) public tempSellerAmountMapping;


    // mapping(address => uint256) public addressToAmountFunded;


    // Orders



    function placeOrder(
        address[] calldata _orderItems,
        uint256[] calldata _units
    ) public payable {
        
       
        // uint256 totalHold = 0;
        // address[] memory orderSellers = new address[](_orderItems.length);
        // uint256[] memory amountSellers = new uint256[](_orderItems.length);

        // uint256 ecmartAmount = 0;
        // uint256 reviewRatingAmount = 0;

        // for (uint256 i = 0; i < _orderItems.length; i++) {
        //     address productAddress = _orderItems[i];
        //     Product product = products[productAddress];
        //     uint256 unit = _units[i];

        //     require(address(product) != address(0), "Product doesn't exist");
        //     require(product.getQuantity() >= unit, "Invalid order");

        //     address seller = product.getSeller();
        //     uint256 price = product.getPrice();
        //     orderSellers[i] = seller;
        //     tempSellerAmountMapping[seller] += price * unit;
        //     ecmartAmount += product.getEcmartAmount() * unit;
        //     reviewRatingAmount += product.getReviewRatingAmount();
        // }

        // address[] memory tempOrderSellers = new address[](_orderItems.length);
        // uint256 index = 0;

        // for (uint256 i = 0; i < orderSellers.length; i++) {
        //     uint256 amount = tempSellerAmountMapping[orderSellers[i]];
        //     if (amount != 0) {
        //         tempOrderSellers[index] = orderSellers[i];
        //         amountSellers[index] = amount;

        //         index++;
        //         tempSellerAmountMapping[orderSellers[i]] = 0;
        //     }
        // }

        // address[] memory finalorderSellers = new address[](index);
        // uint256[] memory finalamountSellers = new uint256[](index);

        // for (uint256 i = 0; i < index; i++) {
        //     finalorderSellers[i] = tempOrderSellers[i];
        //     finalamountSellers[i] = amountSellers[i];
        //     totalHold += finalamountSellers[i];
        // }
        // uint256[] memory finalamountDeliveryMan = new uint256[](index);

        // for (uint256 i = 0; i < index; i++) {
        //     finalamountDeliveryMan[i] = deliveryManChargePerSeller;
        //     totalHold += finalamountDeliveryMan[i];
        // }

        // totalHold += ecmartAmount;
        // totalHold += reviewRatingAmount;


        // amount calculation starts

        require(
            _orderItems.length == _units.length,
            "Arrays must have the same length"
        );

        uint256 orderTotalSellerPayable = 0;
        uint256 orderTotalDeliveryManPayable = 0;
        uint256 orderTotalEcMartPayable = 0;
        uint256 orderTotalReviewRatingPayable = 0;
        uint256 TOTAL_PAYABLE = 0;
        uint256[] memory orderUnitPrice =  new uint256[](_orderItems.length);

         for (uint256 i = 0; i < _orderItems.length; i++) {
            address productAddress = _orderItems[i];
            Product product = products[productAddress];
            uint256 unit = _units[i];

            require(address(product) != address(0), "Product doesn't exist");
            require(product.getQuantity() >= unit, "Invalid order");

            orderUnitPrice[i] = product.getPrice();

            orderTotalSellerPayable += product.getPrice() * unit;
            orderTotalDeliveryManPayable += deliveryManChargePerUnit * unit;
            orderTotalEcMartPayable += product.getEcmartAmount() * unit;
            orderTotalReviewRatingPayable += product.getReviewRatingAmount() * unit;
         }

         TOTAL_PAYABLE = orderTotalSellerPayable + orderTotalDeliveryManPayable + orderTotalEcMartPayable + orderTotalReviewRatingPayable;


        // amount calculation ends

        // hold money starts

        require(msg.value.getConversionRate() >= TOTAL_PAYABLE, "You need to spend more ETH!");

        // hold money ends

        // Create orders starts

        Order order = new Order(msg.sender, _orderItems, _units, address(this), TOTAL_PAYABLE, orderUnitPrice);
        orders[address(order)] = order;

        // Create orders ends

        // Product Quantity update starts
         for (uint256 i = 0; i < _orderItems.length; i++) {
            address productAddress = _orderItems[i];
            Product product = products[productAddress];
            uint256 unit = _units[i];
            product.updateQuantity(product.getQuantity() - unit);
         }
        // Product Quantity update ends
    }

    function setDeliveryMan(address orderAddress, address deliveryManAddress) public {
        Order order = orders[orderAddress];
        
        require(deliveryMen[deliveryManAddress] != address(0), "Invalid delivery man");
        require(address(order) != address(0), "Invalid order");
        require(order.getDeliveryMan() == address(0), "Delivery man is already set");
        
        order.setDeliveryMan(deliveryManAddress);
    }

    function setDelivery(address orderAddress, address[] memory _deliveryItems, uint256[] memory _deliveryUnits){
        Order order = orders[orderAddress];
        require(_deliveryItems.length == _deliveryUnits.length,"Arrays must have the same length");
        require(address(order) != address(0), "Invalid order");
        require(order.getDeliveryMan() == msg.sender, "Invalid delivery man");
        require(order.getIsDelivered() == false, "already delivered");


    }

    function payOrder(address orderAddress) public {
        Order order = orders[orderAddress];

        require(address(order) != address(0), "Invalid order");
        require(order.getIsDelivered() == false, "Already Paid");
        require(
            msg.sender == order.getBuyer(),
            "Only the buyer can pay the bill"
        );
        address[] deliveredItems = order.getDeliveredItems();
        uint256[] deliveredUnits = order.getDeliveredUnits();

        // send to seller

        uint256 sellersPaid = 0;
        uint256 deliveryManPaid = 0;
        uint256 ecMartPaid = 0;
        uint256 reviewRatingPaid = 0;
        for(uint256 i = 0; i < deliveredItems.length; i++){
            address productAddress = deliveredItems[i];
            Product product = products[productAddress];
            uint256 unitPrice = order.getProductWiseUnitPrice(productAddress);
            uint256 units = deliveredUnits[i];

            uint256 deliveryManPaid += units * deliveryManChargePerUnit;
            uint256 ecMartPaid += units * product.getEcmartAmount();
            uint256 reviewRatingPaid += units * product.getReviewRatingAmount();

            uint256 sellerPayable = units * unitPrice;

            (bool callSuccess, ) = payable(product.getSeller()).call{value: sellerPayable}("");
    
            require(callSuccess, "Call failed");

            sellersPaid += sellerPayable;
        }

        // 

        // send to delivery man

        (bool callSuccessDeliveryMan, ) = payable(order.getDeliveryMan()).call{value: deliveryManPaid}("");
    
        require(callSuccessDeliveryMan, "Call failed");

        // 

        // send to ecMart
        (bool callSuccessEcMart, ) = payable(ECMART_ADDRESS).call{value: ecMartPaid}("");
    
        require(callSuccessEcMart, "Call failed");
        // 

        // send to review rating
        (bool callSuccessReviewRating, ) = payable(REVIEW_RATING_ADDRESS).call{value: reviewRatingPaid}("");
    
        require(callSuccessReviewRating, "Call failed");
        //

        // set delivered status
        order.setIsDelivered(true);
        //

        // refund buyer
        uint256 refundable = order.getBuyerTotalPaid() - (sellersPaid + deliveryManPaid + ecMartPaid + reviewRatingPaid);
        (bool callSuccessRefund, ) = payable(order.getBuyer()).call{value: refundable}("");
    
        require(callSuccessRefund, "Call failed");
        //

        // set refund amount staus
        order.setIsRefunded(true);
        order.setRefundedAmount(refundable);
        // 
    }

    function refund(address orderAddress) public {}

    //

    //Products

    function addProduct(
        string memory _name,
        uint256 _price,
        string memory _description,
        uint256 _quantity
    ) public {
        require(sellers[msg.sender] == 1, "You are not a seller");
        Product product = new Product(
            _name,
            _price,
            _description,
            _quantity,
            msg.sender,
            address(this)
        );
        products[address(product)] = product;
    }

    // methods for product update and delete

    //

    //  seller

    function registerSeller() public {
        // need to add admin access control
        sellers[msg.sender] = 1;
    }

    //

    // buyer

    function registerBuyer() public {
        buyers[msg.sender] = 2;
    }

    //

    // deliveryMen

    function registerDeliveryMan() public {
        // need to add admin access control
        deliveryMen[msg.sender] = 3;
    }

    //
}
