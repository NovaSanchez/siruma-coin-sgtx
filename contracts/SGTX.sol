pragma solidity ^0.8.20;


contract SigatTokenX  {

    address private _owner;
    string public _name;
    string public _symbol;
    uint256 private _supply;
    constructor(string memory name_, string memory symbol_, uint256 supply_) {
        _owner = msg.sender;
        _supply = supply_;
        _name = name_;
        _supply = supply_;
    }

}

