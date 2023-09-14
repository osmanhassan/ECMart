//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import {AppStorage} from "./AppStorage.sol";
import "./Product.sol";
import "./Order.sol";

contract PlaceOrderFacet {
    AppStorage aps;
    uint8 private deliveryManChargePerUnit = 3;

    function calculateOrderAmount(
        address[] calldata _orderItems,
        uint256[] calldata _units
    ) private view returns (uint256, uint256[] memory, uint256[] memory) {
        require(
            _orderItems.length == _units.length,
            "Arrays must have the same length"
        );

        uint256 orderTotalSellerPayable = 0;
        uint256 orderTotalDeliveryManPayable = 0;
        uint256 orderTotalEcMartPayable = 0;
        uint256 orderTotalReviewRatingPayable = 0;
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

            orderTotalSellerPayable += product.getPrice() * unit;
            orderTotalDeliveryManPayable += deliveryManChargePerUnit * unit;
            orderTotalEcMartPayable += product.getEcmartAmount() * unit;
            // **** REview Rating is not unit specific
            orderTotalReviewRatingPayable += product.getReviewRatingAmount();
        }
        TOTAL_PAYABLE =
            orderTotalSellerPayable +
            orderTotalDeliveryManPayable +
            orderTotalEcMartPayable +
            orderTotalReviewRatingPayable;
        return (TOTAL_PAYABLE, orderUnitPrice, orderUnitFinalPrice);
    }

    function placeOrder(
        address[] calldata _orderItems,
        uint256[] calldata _units
    ) public payable {
        (
            uint256 TOTAL_PAYABLE,
            uint256[] memory orderUnitPrice,
            uint256[] memory orderUnitFinalPrice
        ) = calculateOrderAmount(_orderItems, _units);

        // hold money starts

        //****  need implement getConversionRate() method
        require(msg.value >= TOTAL_PAYABLE, "You need to spend more ETH!");

        // hold money ends

        // Create orders starts

        Order order = new Order(
            msg.sender,
            _orderItems,
            _units,
            address(this),
            TOTAL_PAYABLE,
            orderUnitPrice,
            orderUnitFinalPrice
        );
        aps.orders[address(order)] = 1;

        // Create orders ends

        // Product Quantity update starts
        for (uint256 i = 0; i < _orderItems.length; i++) {
            address productAddress = _orderItems[i];
            Product product = Product(productAddress);
            uint256 unit = _units[i];
            product.updateQuantity(product.getQuantity() - unit);
        }
        // Product Quantity update ends
    }
}

contract DeliveryFacet {
    AppStorage aps;

    function setDeliveryMan(
        address orderAddress,
        address deliveryManAddress
    ) public {
        require(
            aps.deliveryMen[deliveryManAddress] != 0,
            "Invalid delivery man"
        );
        require(aps.orders[orderAddress] != 0, "Invalid order");
        Order order = Order(orderAddress);
        // deliveryMen[deliveryManAddress] != address(0) , wrong logic

        require(
            order.getDeliveryMan() == address(0),
            "Delivery man is already set"
        );

        order.setDeliveryMan(deliveryManAddress);
    }

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
}

contract PayOrderFacet {
    AppStorage aps;
    uint8 private deliveryManChargePerUnit = 3;
    address ECMART_ADDRESS = 0x5e0f2Ba30E568e51247935E3fD25B2045Bf9D57F;
    address REVIEW_RATING_ADDRESS = 0xA4B18c3a5a3bdDDe4bD880A434e9f7341D16283E;

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

        // send to seller  --> Only for Delivered Goods

        uint256 sellersPaid = 0;
        uint256 deliveryManPaid = 0;
        uint256 ecMartPaid = 0;
        uint256 reviewRatingPaid = 0;
        for (uint256 i = 0; i < deliveredItems.length; i++) {
            address productAddress = deliveredItems[i];
            Product product = Product(productAddress);
            uint256 unitPrice = order.getProductWiseUnitPrice(productAddress);
            uint256 units = deliveredUnits[i];

            deliveryManPaid += units * deliveryManChargePerUnit;
            ecMartPaid += units * product.getEcmartAmount();
            reviewRatingPaid += product.getReviewRatingAmount();

            uint256 sellerPayable = units * unitPrice;

            (bool callSuccess, ) = payable(product.getSeller()).call{
                value: sellerPayable
            }("");

            require(callSuccess, "Call failed");

            sellersPaid += sellerPayable;
        }

        //

        // send to delivery man

        (bool callSuccessDeliveryMan, ) = payable(order.getDeliveryMan()).call{
            value: deliveryManPaid
        }("");

        require(callSuccessDeliveryMan, "Call failed");

        //

        // send to ecMart
        (bool callSuccessEcMart, ) = payable(ECMART_ADDRESS).call{
            value: ecMartPaid
        }("");

        require(callSuccessEcMart, "Call failed");
        //

        // send to review rating
        (bool callSuccessReviewRating, ) = payable(REVIEW_RATING_ADDRESS).call{
            value: reviewRatingPaid
        }("");

        require(callSuccessReviewRating, "Call failed");
        //

        // set delivered status
        order.setIsDelivered(true);
        //

        // refund buyer
        uint256 refundable = order.getBuyerTotalPaid() -
            (sellersPaid + deliveryManPaid + ecMartPaid + reviewRatingPaid);
        (bool callSuccessRefund, ) = payable(order.getBuyer()).call{
            value: refundable
        }("");

        require(callSuccessRefund, "Call failed");
        //

        // set refund amount staus
        order.setIsRefunded(true);
        order.setRefundedAmount(refundable);
        //
    }
}

contract ProductFacet {
    AppStorage aps;

    function addProduct(
        string memory _name,
        uint256 _price,
        string memory _description,
        uint256 _quantity
    ) public {
        // require(aps.sellers[msg.sender] == 1, "You are not a seller");
        Product product = new Product(
            _name,
            _price,
            _description,
            _quantity,
            msg.sender,
            address(this)
        );
        aps.products[address(product)] = 1;
    }

    function getdata(uint256 _data) public view returns (uint256) {
        return _data * 2;
    }
}

contract RegistrationFacet {
    AppStorage aps;

    //  seller

    function registerSeller() public {
        // need to add admin access control
        aps.sellers[msg.sender] = 1;
    }

    //

    // buyer

    function registerBuyer() public {
        aps.buyers[msg.sender] = 2;
    }

    //

    // deliveryMen

    function registerDeliveryMan() public {
        // need to add admin access control
        aps.deliveryMen[msg.sender] = 3;
    }

    //
}

contract Diamond {
    AppStorage aps;

    // address owner;
    mapping(bytes4 => address) public facetMap;

    constructor() {
        // owner = _owner;
        // console.log("tottotot..........");
        PlaceOrderFacet placeOrderFacet = new PlaceOrderFacet();
        DeliveryFacet deliveryFacet = new DeliveryFacet();
        PayOrderFacet payOrderFacet = new PayOrderFacet();
        ProductFacet productFacet = new ProductFacet();
        RegistrationFacet registrationFacet = new RegistrationFacet();

        facetMap[
            bytes4(keccak256("placeOrder(address[],uint256[])"))
        ] = address(placeOrderFacet);

        facetMap[
            bytes4(keccak256("setDeliveryMan(address,address)"))
        ] = address(deliveryFacet);

        facetMap[
            bytes4(keccak256("setDelivery(address,address[],uint256[])"))
        ] = address(deliveryFacet);

        facetMap[bytes4(keccak256("payOrder(address)"))] = address(
            payOrderFacet
        );

        facetMap[
            bytes4(keccak256("addProduct(string,uint256,string,uint256)"))
        ] = address(productFacet);

        facetMap[bytes4(keccak256("getdata(uint256)"))] = address(productFacet);

        facetMap[bytes4(keccak256("registerSeller()"))] = address(
            registrationFacet
        );

        facetMap[bytes4(keccak256("registerBuyer()"))] = address(
            registrationFacet
        );

        facetMap[bytes4(keccak256("registerDeliveryMan()"))] = address(
            registrationFacet
        );

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
    fallback() external {
        address facet = facetMap[msg.sig];
        // console.log(facet);
        require(facet != address(0), "Facet not found");
        // Execute external function from facet using delegatecall and return any value.
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
