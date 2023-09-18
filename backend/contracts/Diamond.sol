//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";
import {AppStorage} from "./AppStorage.sol";
import "./Product.sol";
import "./Order.sol";

contract OrderFacet {
    AppStorage aps;
    using SafeMath for uint256;
    uint256 private deliveryManChargePerUnit = 3;
    uint256 private orderTotalReviewRatingPayable;
    //Lets assume 1USD == 619,202,727,197,760 WEI
    uint256 constant USDtoWEI = 619202727197760;
    //wait
    address ECMART_ADDRESS = 0xbDA5747bFD65F08deb54cb465eB87D40e51B197E;
    address REVIEW_RATING_ADDRESS = 0xbDA5747bFD65F08deb54cb465eB87D40e51B197E;

    event Save(address orderAddress);
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

    // Final Price per unit, ecMart Amount per unit, ReviewRating amount per product, deliveryman amount per unit should be send from backend_offchain to this function --> calculateOrderAmount will not be done ONCHAIN.
    function placeOrder(
        address[] calldata _orderItems,
        uint256[] calldata _units
    ) public payable returns (address) {
        (
            uint256 TOTAL_PAYABLE,
            uint256[] memory orderUnitPrice,
            uint256[] memory orderUnitFinalPrice
        ) = calculateOrderAmount(_orderItems, _units);

        // hold money starts

        //****  need implement getConversionRate() method
        //Lets assume 1USD == 619,202,727,197,760 WEI
        require(
            msg.value >= (TOTAL_PAYABLE * USDtoWEI),
            "You need to spend more ETH!"
        );
        // hold money ends
        // 30000000000000000000
        // 24774301115182377600
        // console.log(TOTAL_PAYABLE * USDtoWEI);
        //excessMoney Refund
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
            orderUnitPrice,
            orderUnitFinalPrice
        );
        aps.orders[address(order)] = 1;
        console.log("Order address ", address(order));
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
        // addBuyer to product
        order.addBuyer();
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

        emit Save(address(order));

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

        // send to seller  --> Only for Delivered Goods

        //Lets assume 1USD == 619,202,727,197,760 WEI
        // uint256 constant USDtoWEI = 619202727197760;

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
            console.log(product.getEcmartAmount());
            ecMartPaid += units * product.getEcmartAmount();
            reviewRatingPaid += product.getReviewRatingAmount();

            uint256 sellerPayable = (units * unitPrice) * USDtoWEI;

            (bool callSuccess, ) = payable(product.getSeller()).call{
                value: sellerPayable
            }("");

            require(callSuccess, "Call failed");

            sellersPaid += sellerPayable;
        }
        // but 40000 th uSD, etake ETH e ekhane convert ki kora hysilo split kore shby k dewar agge?
        // conversion er code to likhi nai ami
        // umm bujhchi
        //
        console.log("Seller Paid");
        console.log(sellersPaid);
        //  2476810908791040000 sellers payable ki ata?
        // send to delivery man
        deliveryManPaid *= USDtoWEI;
        console.log(deliveryManPaid);
        (bool callSuccessDeliveryMan, ) = payable(order.getDeliveryMan()).call{
            value: deliveryManPaid
        }("");

        require(callSuccessDeliveryMan, "Call failed");
        console.log("deliveryman Paid");
        console.log(deliveryManPaid);

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

        // // send to review rating
        // reviewRatingPaid *= USDtoWEI;
        // (bool callSuccessReviewRating, ) = payable(REVIEW_RATING_ADDRESS).call{
        //     value: reviewRatingPaid
        // }("");

        // require(callSuccessReviewRating, "Call failed");
        //

        // set delivered status
        order.setIsDelivered(true);
        //

        // refund buyer
        // uint256 refundable = order.getBuyerTotalPaid() -
        //     (sellersPaid + deliveryManPaid + ecMartPaid + reviewRatingPaid);

        // (bool callSuccessRefund, ) = payable(order.getBuyer()).call{
        //     value: refundable
        // }("");

        // require(callSuccessRefund, "Call failed");
        // console.log("refunded to buyer ");
        // console.log(refundable);
        // //

        // // set refund amount staus
        // order.setIsRefunded(true);
        // order.setRefundedAmount(refundable);
        //
        emit OrderPaid(true);
    }
}

// Bujhi nai. Seller ar DM set kora thik ache naki?
contract DeliveryFacet {
    AppStorage aps;

    function setDeliveryMan(
        address orderAddress // address deliveryManAddress
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

contract ProductFacet {
    AppStorage aps;

    mapping(address => address[]) sellerToProducts;

    // event Save(address productAddress);

    function addProduct(
        string memory _name,
        uint256 _price,
        string memory _description,
        uint256 _quantity
    ) public returns (Product) {
        require(aps.sellers[msg.sender] == 1, "You are not a seller");
        Product product = new Product(
            _name,
            _price,
            _description,
            _quantity,
            msg.sender,
            address(this)
        );
        address productAddress = address(product);
        console.log(productAddress);
        sellerToProducts[msg.sender].push(productAddress);
        aps.products[address(product)] = 1;
        // emit Save(productAddress);
        return product;
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
        ProductFacet productFacet = new ProductFacet();
        RegistrationFacet registrationFacet = new RegistrationFacet();
        aps.deliveryManChargePerUnit = 3;
        facetMap[
            bytes4(keccak256("placeOrder(address[],uint256[])"))
        ] = address(orderFacet);

        facetMap[bytes4(keccak256("setDeliveryMan(address)"))] = address(
            deliveryFacet
        );

        facetMap[
            bytes4(keccak256("setDelivery(address,address[],uint256[])"))
        ] = address(deliveryFacet);

        facetMap[bytes4(keccak256("payOrder(address)"))] = address(orderFacet);

        facetMap[
            bytes4(keccak256("addProduct(string,uint256,string,uint256)"))
        ] = address(productFacet);

        facetMap[bytes4(keccak256("viewProducts(address)"))] = address(
            productFacet
        );

        // facetMap[bytes4(keccak256("getdata(uint256)"))] = address(productFacet);

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
    fallback() external payable {
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
