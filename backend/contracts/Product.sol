// SPDX-License-Identifier: UNLICENSED

// New function added
//  function enableReviewRating(address buyer_address)
// function submitReviewRating(string memory review, uint8 rating)

//Function Modified

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Product {
    // // Assume 5% of produt_actual price
    // uint256 private ecMartPercentage = 5;
    // // Assume 3 ETH per delivery
    // uint256 private reviewRatingAmount = 3000000000000000000;
    // uint256 private deliverymanAmount = 3000000000000000000;
    string name;
    uint256 private price;
    uint256 quantity;
    uint256 ecMartAmount;
    string description;
    address seller;
    address owner;
    uint256 public finalProductPrice;

    mapping(address => uint256) ordersOfProduct; //Which order has ordered how many units
    address[] public orders;

    // List of buyers of the product
    address[] public buyers;
    // Need to check whether the buyer purchased before giving review and rating --> Function
    mapping(address => uint32) buyersToHowManyTimesOrdered; // map buyer->how_many_times_ordered the product

    struct reviewRatingStruct {
        // no need to store order_info in reviewRating
        //review rating is product specific
        string[] reviews;
        uint8[] ratings;
        uint256[] reviewTime;
    }
    mapping(address => reviewRatingStruct) buyerToReviewRating;

    constructor(
        string memory _name,
        uint256 _price,
        string memory _description,
        uint256 _quantity,
        address _seller,
        address _owner,
        uint256 _finalPrice
    ) {
        name = _name;
        price = _price;
        quantity = _quantity;
        description = _description;
        seller = _seller;
        owner = _owner;
        finalProductPrice = _finalPrice;
    }

    modifier onlyECmartOrSeller() {
        require(
            msg.sender == owner || msg.sender == seller,
            "Not Owner or seller"
        ); // Custom error message
        _;
    }

    modifier onlyECmart() {
        require(msg.sender == owner, "Not ECMart (owner)");
        _;
    }

    modifier onlyOrder() {
        require(
            ordersOfProduct[msg.sender] != 0,
            "Product is not assosiated with the ORDER"
        );
        _;
    }

    function addOrder(
        address order_address,
        uint256 order_units
    ) public onlyECmart {
        orders.push(order_address);
        ordersOfProduct[order_address] = order_units;
    }

    function addBuyer(address buyer_address) public onlyOrder {
        //if new buyer, add to buyers array
        if (buyersToHowManyTimesOrdered[buyer_address] == 0) {
            buyers.push(buyer_address);
        }
    }

    // call this function when buyer purchases this product --> increase how_many_times a buyer ordered the product
    function enableReviewRating(address buyer_address) public {
        buyersToHowManyTimesOrdered[buyer_address] =
            buyersToHowManyTimesOrdered[buyer_address] +
            1;
    }

    function submitReviewRating(string memory review, uint8 rating) public {
        //check whether he is a buyer
        require(
            buyersToHowManyTimesOrdered[msg.sender] != 0,
            "You are not a buyer of the product"
        );
        // Check whether the buyer exceeds the number_of_reviews with number_of_time they ordered
        require(
            buyersToHowManyTimesOrdered[msg.sender] <
                buyerToReviewRating[msg.sender].ratings.length,
            "You have already provided review and rating of this product"
        );
        uint256 currentTime = block.timestamp;
        buyerToReviewRating[msg.sender].reviews.push(review);
        buyerToReviewRating[msg.sender].ratings.push(rating);
        buyerToReviewRating[msg.sender].reviewTime.push(currentTime);
    }

    function getQuantity() public view returns (uint256) {
        return quantity;
    }


    function getName() public view returns (string memory) {
        return name;
    }
    

    function getPrice() public view onlyECmartOrSeller returns (uint256) {
        return price;
    }

    function getProductFinalPrice() public view returns (uint256) {
        return finalProductPrice;
    }

    // function getEcmartAmount() public view onlyECmart returns (uint256) {
    //     return ecMartAmount;
    // }

    // function getReviewRatingAmount() public view returns (uint256) {
    //     return reviewRatingAmount;
    // }

    // function getDelivermanAmount() public view returns (uint256){
    //     return deliverymanAmount;
    // }

    function getSeller() public view returns (address) {
        return seller;
    }

    function updateQuantity(uint256 _quantity) public onlyECmartOrSeller {
        quantity = _quantity;
    }
}
