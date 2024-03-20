// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
     
     library LibERC20AppStorage{
     
     struct ERC20Layout{
     string name;
     string symbol;
     uint decimal;
     uint _totalSupply;
     address _TokenOwner;

     mapping(address=>uint) balances;
     mapping (address=>mapping(address=>uint256)) allowances;

     }
     }


  