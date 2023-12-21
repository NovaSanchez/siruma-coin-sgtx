// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.17;

contract exampleSoft {

    struct lol {
        string lolOne;
        string loltwo;
        string loltree;
        bool isValid;
    }

    bool someBoolVar = true;

    mapping (string => lol) mp;

    function make(string memory a, string memory b, string memory c) public payable returns(bool) {
        lol memory obj = lol(a,b,c, true);
        mp[a] = obj;
        return true;
    }
    

    function views(string memory a) public view returns(bool) {
        lol memory obj = mp[a];
        if(obj.isValid == false ) {
            return false;
        }
        return true;
    }

    function check() external view returns(bool ){
        return someBoolVar;

    }
}