// I'm a comment!
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
// pragma solidity ^0.8.0;
// pragma solidity >=0.8.0 <0.9.0;

contract SimpleStorage {

    uint256 favoriteNumber;

     function store(uint256 _favoriteNumber) public virtual {
        favoriteNumber = _favoriteNumber;
    }
    
    //view, pure doesn't require Gas
    function retrieve() public view returns (uint256){
        return favoriteNumber;
    }



    struct People {
        uint256 favoriteNumber;
        string name;
    }
    // uint256[] public anArray;
    People[] public people;

    mapping(string => uint256) public nameToFavoriteNumber;
    mapping(uint256 => string) public favNumToName;   


    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        people.push(People(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
        favNumToName[_favoriteNumber] = _name;
    }

    function getPeople(uint256 _index) view public returns (string memory, uint256){
        string memory namePerson = people[_index].name;
        uint256 favNum = people[_index].favoriteNumber; 
        return (namePerson, favNum);
    }
}
