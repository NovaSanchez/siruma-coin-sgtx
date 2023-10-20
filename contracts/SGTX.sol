pragma solidity ^0.8.20;


contract SigatTokenX  {

    address private _owner;
    string public _name;
    string public _symbol;
    uint256 private _supply;

    mapping(address => uint256) public _balances;
    mapping(address => bool) public _holders;
    mapping(address => bool) public _holdersFreeze;


    constructor(string memory name_, string memory symbol_, uint256 supply_) {
        _owner = msg.sender;
        _supply = supply_;
        _name = name_;
        _supply = supply_;
    }

    //  function decimals() public view virtual returns (uint8) {
    //     return 8;
    // }
 
    // function totalSupply() public view virtual returns (uint256) {
    //     return _totalSupply;
    // }

    // function balanceOf(address account) public view virtual returns (uint256) {
    //     return _balances[account];
    // }

    // function name() public view virtual returns (string memory) {
    //     return _name;
    // }

    // function symbol() public view virtual returns (string memory) {
    //     return _symbol;
    // }

    // function transfer(address to, uint256 value) public virtual returns (bool) {
    //     address owner = _msgSender();
    //     _transfer(owner, to, value);
    //     return true;
    // }

    modifier isOwner() {
        require(
            msg.sender == _owner,
            'Only Owner con activate'
        );
        _;
    }

    modifier isZeroAddress() {
        require(
            msg.sender == _owner,
            'Only Owner con activate'
        );
        _;
    }

    function TranferOwner( address newOwner) public virtual isOwner return (address) {

        _owner = newOwner;
    }

}

