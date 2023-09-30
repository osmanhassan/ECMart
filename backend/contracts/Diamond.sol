//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import {AppStorage} from "./AppStorage.sol";
import "./Product.sol";
import "./Order.sol";

contract OrderFacet {
    AppStorage aps;
    // using SafeMath for uint256;

    uint256 private orderTotalReviewRatingPayable;

    event Save(address orderAddress, uint256 dbId);
    event OrderPaid(bool isPaid);

    // Calculate amount will be done in the backend
    function calculateOrderAmount(
        address[] calldata _orderItems,
        uint256[] calldata _units
    ) private returns (uint256, uint256[] memory, uint256[] memory) {
        require(
            _orderItems.length == _units.length,
            "Arrays must have the same length"
        );

        uint256 orderTotalSellerPayable = 0;
        uint256 orderTotalDeliveryManPayable = 0;
        uint256 orderTotalEcMartPayable = 0;
        orderTotalReviewRatingPayable = 0;
        uint256 TOTAL_PAYABLE = 0;
        //check what happens
        uint256[] memory orderUnitPrice = new uint256[](_orderItems.length);
        uint256[] memory orderUnitFinalPrice = new uint256[](
            _orderItems.length
        );

        for (uint256 i = 0; i < _orderItems.length; i++) {
            address productAddress = _orderItems[i];

            require(aps.products[productAddress] != 0, "Product doesn't exist");
            Product product = Product(productAddress);
            uint256 unit = _units[i];

            require(
                product.getQuantity() >= unit,
                "Product inventory is not Sufficient"
            );

            orderUnitPrice[i] = product.getPrice();
            orderUnitFinalPrice[i] = product.getProductFinalPrice();

            TOTAL_PAYABLE += orderUnitFinalPrice[i] * _units[i];

            // orderTotalSellerPayable += product.getPrice() * unit;
            // orderTotalDeliveryManPayable += aps.deliveryManChargePerUnit * unit;
            // //***************** ERROR MIGHT OCCUR */ for division operation
            // orderTotalEcMartPayable +=
            //     ((aps.ecMartPercentage * orderUnitPrice[i]) / 100) *
            //     unit;
            // orderTotalReviewRatingPayable += aps.reviewRatingAmount * unit;
        }
        // TOTAL_PAYABLE =
        //     orderTotalSellerPayable +
        //     orderTotalDeliveryManPayable +
        //     orderTotalEcMartPayable +
        //     orderTotalReviewRatingPayable;
        return (TOTAL_PAYABLE, orderUnitPrice, orderUnitFinalPrice);
    }

    // Final Price per unit, ecMart Amount per unit, ReviewRating amount per product, deliveryman amount per unit should be send from backend_offchain to this function --> calculateOrderAmount will not be done ONCHAIN.
    function placeOrder(
        address[] calldata _orderItems,
        uint256[] calldata _units,
        uint256 dbId
    ) public payable returns (address) {
        (
            uint256 TOTAL_PAYABLE,
            uint256[] memory orderUnitPrice,
            uint256[] memory orderUnitFinalPrice
        ) = calculateOrderAmount(_orderItems, _units);

        // hold money starts

        //****  need implement getConversionRate() method
        //Lets assume 1USD == 619,202,727,197,760 WEI
        console.log(TOTAL_PAYABLE);
        require(msg.value >= (TOTAL_PAYABLE), "You need to spend more ETH!");
        // hold money ends

        // excessMoney Refund
        // uint256 val = (TOTAL_PAYABLE * USDtoWEI);
        // val.sub(msg.value);
        // (bool success, ) = msg.sender.call{value: excessFund}("");
        // require(success, "Excess Fund Transfer Failed");

        // Create orders starts

        Order order = new Order(
            msg.sender,
            _orderItems,
            _units,
            address(this),
            TOTAL_PAYABLE,
            msg.value,
            orderUnitPrice,
            orderUnitFinalPrice
        );
        aps.orders[address(order)] = 1;
        console.log("Order address ", address(order));
        console.log("Order TOTAL PAYABLE ", TOTAL_PAYABLE);
        // add order address to products ---> WIN
        for (uint32 i = 0; i < _orderItems.length; i++) {
            (bool successOrdertoProduct, ) = _orderItems[i].call(
                abi.encodeWithSignature(
                    "addOrder(address,uint256)",
                    order,
                    _units[i]
                )
            );
            require(
                successOrdertoProduct,
                "Order added to Products is UNSUCCESSFUL!! from ECmart contract"
            );
        }

        // Create orders ends

        // Product Quantity update starts
        for (uint256 i = 0; i < _orderItems.length; i++) {
            address productAddress = _orderItems[i];
            Product product = Product(productAddress);
            uint256 unit = _units[i];
            product.updateQuantity(product.getQuantity() - unit);
        }
        // Product Quantity update ends

        //Fund Transfer to ORDER starts

        // FUND Transfers to ORDER ends

        emit Save(address(order), dbId);

        return address(order);
    }

    function payOrder(address orderAddress) public {
        require(aps.orders[orderAddress] != 0, "Invalid order");
        Order order = Order(orderAddress);
        require(order.getIsDelivered() == false, "Already Paid");
        require(
            msg.sender == order.getBuyer(),
            "Only the buyer can pay the bill"
        );
        address[] memory deliveredItems = order.getDeliveredItems();
        uint256[] memory deliveredUnits = order.getDeliveredUnits();
        address buyer = order.getBuyer();

        // send to seller  --> Only for Delivered Goods

        uint256 sellersPaid = 0;
        uint256 deliveryManPaid = 0;
        uint256 ecMartPaid = 0;
        uint256 reviewRatingPaid = 0;
        // uint256 balance = (address)this.balance;

        console.log("inside pay order");
        for (uint256 i = 0; i < deliveredItems.length; i++) {
            address productAddress = deliveredItems[i];
            Product product = Product(productAddress);

            uint256 unitPrice = order.getProductWiseUnitPrice(productAddress);
            uint256 units = deliveredUnits[i];

            deliveryManPaid += (units * aps.deliveryManChargePerUnit);

            ecMartPaid += units * ((unitPrice * aps.ecMartPercentage) / 100);
            reviewRatingPaid += (units * aps.reviewRatingAmount);

            //Seller Pay
            uint256 sellerPayable = (units * unitPrice);
            (bool callSuccess, ) = payable(product.getSeller()).call{
                value: sellerPayable
            }("");
            require(callSuccess, "Seller Fund Transafer Failed!!");

            sellersPaid += sellerPayable;
        }

        console.log("Seller Paid");
        console.log(sellersPaid);

        (bool callSuccessDeliveryMan, ) = payable(order.getDeliveryMan()).call{
            value: deliveryManPaid
        }("");
        require(callSuccessDeliveryMan, "Delivery Man Transafer Failed!!");

        console.log("deliveryman Paid : ", deliveryManPaid);

        //

        // // send to ecMart
        // console.log("Ecmart payable");
        // console.log(ecMartPaid);
        // ecMartPaid *= USDtoWEI;
        // (bool callSuccessEcMart, ) = payable(ECMART_ADDRESS).call{
        //     value: ecMartPaid
        // }("");

        // require(callSuccessEcMart, "Call failed");
        // balance to nai.. kano?

        // send to review rating

        // (bool callSuccessRvwRtng, ) = payable(msg.sender).call{
        //     value: reviewRatingPaid
        // }("");
        // require(callSuccessRvwRtng, "Review Rating Transfer Failed!!");

        // console.log("reviewRatingPaid : ", reviewRatingPaid);

        // require(callSuccessReviewRating, "Call failed");
        //

        // set delivered status
        order.setIsDelivered(true);
        //

        // refund buyer
        uint256 refundable = order.getBuyerTotalPaid() -
            (sellersPaid + deliveryManPaid + ecMartPaid);

        (bool callSuccessRefund, ) = payable(order.getBuyer()).call{
            value: refundable
        }("");

        require(callSuccessRefund, "Refund Failed");
        console.log("refunded to buyer ");
        console.log(refundable);
        // //

        // set refund amount staus
        order.setIsRefunded(true);
        order.setRefundedAmount(refundable);

        //
        //Enable ReviewRating || REview and rating can be submitted even when the product is not delivered.
        for (uint32 i = 0; i < deliveredItems.length; i++) {
            Product product = Product(deliveredItems[i]);
            product.enableReviewRating(buyer);
            // Call the function of Product Contract without importing Product.sol using function signature --> dynamic approach
            // (bool success, ) = deliveredItems[i].call(
            //     abi.encodeWithSignature("enableReviewRating(address)", buyer)
            // );
            // require(success, "Review-Rating Permission given is FAILED!!");
        }

        emit OrderPaid(true);
    }
}

// Bujhi nai. Seller ar DM set kora thik ache naki?
contract DeliveryFacet {
    AppStorage aps;
    event deliveryManSet(uint256 orderDBID, uint256 dmDBID);

    function getDelivery(
        address orderAddress
    )
        public
        view
        returns (
            string[] memory,
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        require(aps.orders[orderAddress] != 0, "Invalid order");
        Order order = Order(orderAddress);
        address[] memory deliveredItems = order.getDeliveredItems();
        uint256[] memory deliveredUnits = order.getDeliveredUnits();
        string[] memory names = new string[](deliveredItems.length);
        uint256[] memory itemTotal = new uint256[](deliveredItems.length);
        uint256[] memory unitPrice = new uint256[](deliveredItems.length);
        uint256[] memory dbId = new uint256[](deliveredItems.length);

        for (uint16 i = 0; i < deliveredItems.length; i++) {
            Product product = Product(deliveredItems[i]);
            names[i] = product.getName();
            dbId[i] = product.getDbId();
            itemTotal[i] = product.getProductFinalPrice() * deliveredUnits[i];
            unitPrice[i] = product.getProductFinalPrice();
        }
        // crucial function
        return (names, deliveredItems, deliveredUnits, unitPrice, itemTotal, dbId);
    }

    function setDeliveryMan(
        address orderAddress,
        uint256 orderDBID,
        uint256 dmDBID // address deliveryManAddress
    ) public {
        require(aps.deliveryMen[msg.sender] != 0, "Invalid delivery man");
        require(aps.orders[orderAddress] != 0, "Invalid order");
        Order order = Order(orderAddress);
        // deliveryMen[deliveryManAddress] != address(0) , wrong logic

        require(
            order.getDeliveryMan() == address(0),
            "Delivery man is already set"
        );

        order.setDeliveryMan(msg.sender);
        emit deliveryManSet(orderDBID, dmDBID);

        // send reviewRating fund to buyer
    }

    // Seller items provide to deliverMAn???
    function setDelivery(
        address orderAddress,
        address[] memory _deliveryItems,
        uint256[] memory _deliveryUnits
    ) public {
        require(
            _deliveryItems.length == _deliveryUnits.length,
            "Arrays must have the same length"
        );
        require(aps.orders[orderAddress] != 0, "Invalid order");
        Order order = Order(orderAddress);
        require(order.getDeliveryMan() == msg.sender, "Invalid delivery man");
        require(order.getIsDelivered() == false, "already delivered");

        order.setDelivery(_deliveryItems, _deliveryUnits);
    }

    //Buyer verifyDelivery
}

contract ReviewRatingFacet {
    AppStorage aps;

    //REview-Rating is enabled AUTOMATICALLY DURING payOrder() function

    function provideReviewRating(
        address productAddress,
        string memory _review,
        uint256 _rating
    ) public {
        Product product = Product(productAddress);
        product.submitReviewRating(_review, _rating, msg.sender);
    }

    function getReviewRating(
        address productAddress
    )
        public
        view
        returns (
            address[] memory,
            string[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        Product product = Product(productAddress);
        return product.getReviewRatingOfProduct();
    }

    // function getRating(address productAddress) public view returns (uint256) {
    //     Product product = Product(productAddress);
    //     uint256 totalRatingSum = product.getTotalRatingSum();
    //     uint256 noOfRating = product.getNumOfRating();
    //     return totalRatingSum / noOfRating;
    // }
}

contract ProductFacet {
    AppStorage aps;

    mapping(address => address[]) sellerToProducts;

    event productSaved(
        uint256 _finalPrice,
        address productAddress,
        uint256 dbID
    );

    function addProduct(
        string memory _name,
        uint256 _price,
        string memory _description,
        uint256 _quantity,
        uint256 dbID
    ) public {
        require(aps.sellers[msg.sender] == 1, "You are not a seller");

        uint256 _finalPrice = _price +
            aps.deliveryManChargePerUnit +
            aps.reviewRatingAmount +
            ((_price * aps.ecMartPercentage) / 100);
        console.log("_Final Price of Product : ", _finalPrice);

        Product product = new Product(
            _name,
            _price,
            _description,
            _quantity,
            msg.sender,
            address(this),
            _finalPrice,
            dbID
        );
        address productAddress = address(product);
        console.log(productAddress);
        sellerToProducts[msg.sender].push(productAddress);
        aps.products[address(product)] = 1;
        emit productSaved(_finalPrice, productAddress, dbID);
    }

    function viewProducts(
        address _sellerAddress
    ) public view returns (address[] memory) {
        return sellerToProducts[_sellerAddress];
    }

    // function getdata(uint256 _data) public view returns (uint256) {
    //     return _data * 2;
    // }
}

contract RegistrationFacet {
    AppStorage aps;

    //  seller
    event registered(address registrationAddress, uint256 dbID);

    function registerSeller(uint256 dbID) public {
        // need to add admin access control
        aps.sellers[msg.sender] = 1;
        console.log("Seller registered : ", msg.sender);
        emit registered(msg.sender, dbID);
    }

    //need to compile i guess
    //

    // buyer
    // event buyerRegistered(address buyerAddress, uint256 dbID);

    function registerBuyer(uint256 dbID) public {
        aps.buyers[msg.sender] = 2;
        console.log("Buyer Registered : ", msg.sender);
        emit registered(msg.sender, dbID);
    }

    //

    // deliveryMen
    // event dmRegistered(address dmAddress, uint256 dbID);

    function registerDeliveryMan(uint256 dbID) public {
        // need to add admin access control
        aps.deliveryMen[msg.sender] = 3;
        console.log("Deliveryman Registered : ", msg.sender);
        emit registered(msg.sender, dbID);
    }

    //
}

contract Diamond {
    AppStorage aps;

    // address owner;
    mapping(bytes4 => address) public facetMap;

    // must contain all the buyers
    // must contain all the seller
    // must contain all the deliveryman
    // must contain all the order
    //NEED to MAP seller_address => Product[] == Seller own Product List View

    constructor() {
        // owner = _owner;
        // console.log("tottotot..........");
        OrderFacet orderFacet = new OrderFacet();
        DeliveryFacet deliveryFacet = new DeliveryFacet();
        ReviewRatingFacet reviewRatingFacet = new ReviewRatingFacet();
        ProductFacet productFacet = new ProductFacet();
        RegistrationFacet registrationFacet = new RegistrationFacet();

        // // Assume 5% of produt_actual price
        // // Assume 3 ETH per delivery and reviewRating
        aps.deliveryManChargePerUnit = 3000000000000000000;
        aps.reviewRatingAmount = 3000000000000000000;
        aps.ecMartPercentage = 5;
        facetMap[
            bytes4(keccak256("placeOrder(address[],uint256[],uint256)"))
        ] = address(orderFacet);

        facetMap[
            bytes4(keccak256("setDeliveryMan(address,uint256,uint256)"))
        ] = address(deliveryFacet);

        facetMap[
            bytes4(keccak256("setDelivery(address,address[],uint256[])"))
        ] = address(deliveryFacet);

        facetMap[bytes4(keccak256("getDelivery(address)"))] = address(
            deliveryFacet
        );

        facetMap[bytes4(keccak256("payOrder(address)"))] = address(orderFacet);

        facetMap[
            bytes4(
                keccak256("addProduct(string,uint256,string,uint256,uint256)")
            )
        ] = address(productFacet);

        facetMap[bytes4(keccak256("viewProducts(address)"))] = address(
            productFacet
        );

        // facetMap[bytes4(keccak256("getdata(uint256)"))] = address(productFacet);

        facetMap[bytes4(keccak256("registerSeller(uint256)"))] = address(
            registrationFacet
        );

        facetMap[bytes4(keccak256("registerBuyer(uint256)"))] = address(
            registrationFacet
        );

        facetMap[bytes4(keccak256("registerDeliveryMan(uint256)"))] = address(
            registrationFacet
        );

        // facetMap[bytes4(keccak256("getRating(address)"))] = address(
        //     reviewRatingFacet
        // );
        facetMap[bytes4(keccak256("getReviewRating(address)"))] = address(
            reviewRatingFacet
        );
        facetMap[
            bytes4(keccak256("provideReviewRating(address,string,uint256)"))
        ] = address(reviewRatingFacet);

        // bytes32 x = keccak256("addProduct(string,uint256,string,uint256)");
        // string memory converted = bytes32ToString(x);
        // console.log("hello");
    }

    // function bytes32ToString(
    //     bytes32 _bytes32
    // ) public pure returns (string memory) {
    //     uint8 i = 0;
    //     while (i < 32 && _bytes32[i] != 0) {
    //         i++;
    //     }
    //     bytes memory bytesArray = new bytes(i);
    //     for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
    //         bytesArray[i] = _bytes32[i];
    //     }
    //     return string(bytesArray);
    // }

    // Fallback function to delegate calls to facets
    fallback() external payable {
        address facet = facetMap[msg.sig];
        // console.log(facet);
        require(facet != address(0), "Facet not found");
        // Execute external function from facet using delegatecall and return any value.

        console.log("akjshdkajhdakjdhakjdhakdjh");
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize()) // copies the calldata into memory (this is where delegatecall loads from)
            // execute function call against the relevant facet
            // note that we send in the entire calldata including the function selector
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                // delegate call failed
                revert(0, returndatasize()) // so revert
            }
            default {
                return(0, returndatasize()) // delegatecall succeeded, return any return data
            }
        }
    }
}
