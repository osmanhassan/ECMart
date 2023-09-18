//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";

struct AppStorage {
   uint256 tester;
    mapping(address => uint8)  orders;
    mapping(address => uint8)  products;
    mapping(address => uint8)  sellers;
    mapping(address => uint8)  buyers;
    mapping(address => uint8)  deliveryMen;
    uint256 deliveryManChargePerUnit;
}