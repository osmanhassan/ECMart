pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "./Product.sol";
import "./Order.sol";

contract ECMart {
    uint256 private deliveryManChargePerSeller = 3;

    mapping(address => Order) public orders;
    mapping(address => Product) public products;
    mapping(address => uint8) public sellers;
    mapping(address => uint8) public buyers;
    mapping(address => uint8) public deliveryMen;
    mapping(address => uint256) public tempSellerAmountMapping;

    // Orders
    function placeOrder(
        address[] calldata _orderItems,
        uint256[] calldata _units
    ) public payable {
        // amount calculation starts
        require(
            _orderItems.length == _units.length,
            "Arrays must have the same length"
        );
        uint256 totalHold = 0;
        address[] memory orderSellers = new address[](_orderItems.length);
        uint256[] memory amountSellers = new uint256[](_orderItems.length);

        uint256 ecmartAmount = 0;
        uint256 reviewRatingAmount = 0;

        for (uint256 i = 0; i < _orderItems.length; i++) {
            address productAddress = _orderItems[i];
            Product product = products[productAddress];
            uint256 unit = _units[i];

            require(address(product) != address(0), "Product doesn't exist");
            require(product.getQuantity() >= unit, "Invalid order");

            address seller = product.getSeller();
            uint256 price = product.getPrice();
            orderSellers[i] = seller;
            tempSellerAmountMapping[seller] += price * unit;
            ecmartAmount += product.getEcmartAmount() * unit;
            reviewRatingAmount += product.getReviewRatingAmount();
        }

        address[] memory tempOrderSellers = new address[](_orderItems.length);
        uint256 index = 0;

        for (uint256 i = 0; i < orderSellers.length; i++) {
            uint256 amount = tempSellerAmountMapping[orderSellers[i]];
            if (amount != 0) {
                tempOrderSellers[index] = orderSellers[i];
                amountSellers[index] = amount;

                index++;
                tempSellerAmountMapping[orderSellers[i]] = 0;
            }
        }

        address[] memory finalorderSellers = new address[](index);
        uint256[] memory finalamountSellers = new uint256[](index);

        for (uint256 i = 0; i < index; i++) {
            finalorderSellers[i] = tempOrderSellers[i];
            finalamountSellers[i] = amountSellers[i];
            totalHold += finalamountSellers[i];
        }
        uint256[] memory finalamountDeliveryMan = new uint256[](index);

        for (uint256 i = 0; i < index; i++) {
            finalamountDeliveryMan[i] = deliveryManChargePerSeller;
            totalHold += finalamountDeliveryMan[i];
        }

        totalHold += ecmartAmount;
        totalHold += reviewRatingAmount;

        // amount calculation ends

        // hold money starts
        // hold money ends

        // Create orders starts
        // Create orders ends

        // Product Quantity update starts
        // Product Quantity update ends
    }

    function payOrder(address orderAddress) public {
        Order order = orders[orderAddress];

        require(address(order) != address(0), "Invalid order");
        require(
            msg.sender == order.getBuyer(),
            "Only the buyer can pay the bill"
        );
    }

    function rollBackPayment() public {}

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
            msg.sender
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
