// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "../1/SimpleStorage.sol"; 

// ExtraStorage inherited SimpleStorage using "is" keyword
contract ExtraStorage is SimpleStorage{
    
    //must add keyword 'override' for overiding a function
    function store (uint256 _favNum) public override {
        favoriteNumber = _favNum + 15;
    }
}