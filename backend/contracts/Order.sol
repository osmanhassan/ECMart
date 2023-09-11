// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Order {
    address public buyer;
    address public deliveryMan;
    // seller wise payables
    mapping(address => uint256) private sellerPayables;
    mapping(address => uint256) public deliveryMenPayables;
    mapping(address => uint256) private ecMartPayables;
    mapping(address => uint256) private reviewRatingPayables;
    //

    uint256 public orderTime;
    address[] orderItems;
    uint256[] units;
    uint256 status;

    constructor(
        address _buyer,
        address[] memory sellers,
        uint256[] memory sellersAmount,
        uint256[] memory deliveryManAmount,
        uint256[] memory _ecMartAmount,
        uint256[] memory _reviewRatingAmount,
        address[] memory _orderItems,
        uint256[] memory _units
    ) {
        require(
            sellers.length == sellersAmount.length &&
                sellers.length == deliveryManAmount.length,
            "Arrays must have the same length"
        );

        orderTime = block.timestamp;

        buyer = _buyer;

        for (uint256 i = 0; i < sellers.length; i++) {
            sellerPayables[sellers[i]] = sellersAmount[i];
            deliveryMenPayables[sellers[i]] = deliveryManAmount[i];
        }
    }

    function getBuyer() public view returns (address) {
        return buyer;
    }
}
