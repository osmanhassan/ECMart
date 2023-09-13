// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Order {
    address public buyer;
    address public deliveryMan;
    address public owner;

    address[] public orderItems;
    uint256[] public orderUnits;
    uint256[] private orderUnitPrice;
    uint256[] private orderUnitFinalPrice;
    address[] public deliveredItems;
    uint256[] public deliveredUnits;

    mapping(address => uint256) orderDetails;
    mapping(address => uint256) productUnitPrice;
    mapping(address => uint256) deliveryDetails;

    uint256 public status;
    uint256 public orderTime;
    bool public isPaid = false;
    uint256 public buyerTotalPaid;
    bool public isRefunded = false;
    uint256 public refundedAmount;
    bool public isDelivered = false;

    constructor(
        address _buyer,
        address[] memory _orderItems,
        uint256[] memory _units,
        address _owner,
        uint256 _buyerTotalPaid,
        uint256[] memory _orderUnitPrice,
        uint256[] memory _orderUnitFinalPrice
    ) {
        require(
            _orderItems.length == _units.length,
            "Arrays must have the same length"
        );
        owner = _owner;
        orderTime = block.timestamp;

        buyer = _buyer;

        orderItems = _orderItems;
        orderUnits = _units;
        orderUnitPrice = _orderUnitPrice;
        orderUnitFinalPrice = _orderUnitFinalPrice;

        buyerTotalPaid = _buyerTotalPaid;
        isPaid = true;

        for (uint256 i = 0; i < _orderItems.length; i++) {
            orderDetails[_orderItems[i]] = _units[i];
            productUnitPrice[_orderItems[i]] = _orderUnitPrice[i];
        }
    }

    modifier onlyECmart() {
        // require(msg.sender == owner);
        require(msg.sender == owner, "Owner only");
        _;
    }

    function getBuyer() public view returns (address) {
        return buyer;
    }

    function getDeliveryMan() public view returns (address) {
        return deliveryMan;
    }

    function getOrderItems() public view returns (address[] memory) {
        return orderItems;
    }

    function getOrderUnits() public view returns (uint256[] memory) {
        return orderUnits;
    }

    function getOrderUnitFinalPrice() public view returns ( uint256[] memory) {
        return orderUnitFinalPrice;
    }

    function getOrderUnitPrice()
        public
        view
        onlyECmart
        returns (uint256[] memory)
    {
        return orderUnitPrice;
    }

    function getDeliveredItems() public view returns (address[] memory) {
        return deliveredItems;
    }

    function getDeliveredUnits() public view returns (uint256[] memory) {
        return deliveredUnits;
    }

    function getIsDelivered() public view returns (bool) {
        return isDelivered;
    }

    //onlybyer and EC
    function getBuyerTotalPaid() public view returns (uint256) {
        return buyerTotalPaid;
    }

    function setIsDelivered(bool _isDelivered) public onlyECmart {
        isDelivered = _isDelivered;
    }

    function setIsRefunded(bool _isRefunded) public onlyECmart {
        isRefunded = _isRefunded;
    }

    function setRefundedAmount(uint256 _refundedAmount) public onlyECmart {
        refundedAmount = _refundedAmount;
    }

    function getProductWiseUnitPrice(
        address productaddress
    ) public view onlyECmart returns (uint256) {
        return productUnitPrice[productaddress];
    }

    function setDeliveryMan(address _deliveryManAddress) public onlyECmart {
        deliveryMan = _deliveryManAddress;
    }

    function setDelivery(
        address[] memory _deliveryItems,
        uint256[] memory _deliveryUnits
    ) public onlyECmart {
        for (uint256 i = 0; i < _deliveryItems.length; i++) {
            require(
                orderDetails[_deliveryItems[i]] <= _deliveryUnits[i],
                "delivery doesn't match with order"
            );
            deliveryDetails[_deliveryItems[i]] = _deliveryUnits[i];
        }

        deliveredItems = _deliveryItems;
        deliveredUnits = _deliveryUnits;
    }
}
