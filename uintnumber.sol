// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract SimpleStorage {

    uint256  number; // public ?


    function store(uint256 number1) public {
        number = number1;
    }

    function retrieve() public view returns(uint256){ //view pure?
        return number;
    }

}