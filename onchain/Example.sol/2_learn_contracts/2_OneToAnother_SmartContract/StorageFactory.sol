// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.7;

import "../1/SimpleStorage.sol"; 

contract StorageFactory {
    
    SimpleStorage[] public simpleStorageArray;
    
    function createSimpleStorageContract() public {
        SimpleStorage simpleStorage = new SimpleStorage();
        simpleStorageArray.push(simpleStorage);
    }
    
    function sfStoreFavNumb(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public {
        // Address 
        // ABI 
        // SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).store(_simpleStorageNumber);
        simpleStorageArray[_simpleStorageIndex].store(_simpleStorageNumber);
    }

    function sfStorePeopleInfo(uint256 _simpleStorageIndex, string memory _name, uint256 _favNum) public {
        simpleStorageArray[_simpleStorageIndex].addPerson(_name, _favNum);
    }
    
    function sfGetFavNum(uint256 _simpleStorageIndex) public view returns (uint256) {
        // return SimpleStorage(address(simpleStorageArray[_simpleStorageIndex])).retrieve();
        return simpleStorageArray[_simpleStorageIndex].retrieve();
    }

    function sfGetPeople(uint256 _simpleStorageIndex, uint256 _simpleStoragePersonIndex) view public returns (string memory, uint256) {
        return simpleStorageArray[_simpleStorageIndex].getPeople(_simpleStoragePersonIndex);
    }
}