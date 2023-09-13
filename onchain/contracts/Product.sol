// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Product {
    uint256 private ecMartPercentage = 2;
    uint256 private reviewRatingAmount = 5;
    string name;
    uint256 private price;
    uint256 quantity;
    uint256 ecMartAmount;
    string description;
    address seller;
    address owner,
    mapping(address => string) rating;
    mapping(address => string) review;

    constructor(
        string memory _name,
        uint256 _price,
        string memory _description,
        uint256 _quantity,
        address _seller,
        address _ownwer,

    ) {
        name = _name;
        price = _price;
        quantity = _quantity;
        description = _description;
        seller = _seller;
        owner = _owner;
        ecMartAmount = price * (ecMartPercentage / 100);
    }

    modifier onlyOwnerOrSeller {
     require(msg.sender == owner || msg.sender == seller, "Not Owner or seller"); // Custom error message
        _;
    }

    function getQuantity() public view returns (uint256) {
        return quantity;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    function getEcmartAmount() public view returns (uint256) {
        return ecMartAmount;
    }

    function getReviewRatingAmount() public view returns (uint256) {
        return reviewRatingAmount;
    }

    function getSeller() public view returns (address) {
        return seller;
    }

    function updateQuantity(uint256 _quantity) public onlyOwnerOrSeller {
        quantity = _quantity;
    }
}
