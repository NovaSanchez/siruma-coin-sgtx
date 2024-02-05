// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "./libs/IERC20.sol";
import {IERC20Errors} from "./libs/draft-IERC6093.sol";



contract SigatTokenX is IERC20, IERC20Errors {
    address private _owner;
    string private _name;
    string private _symbol;
    uint256 private _supply;
    uint8 private _decimals;
    bool private _paused;
    bool private _freeTranfer;

    mapping(address => uint256) public _balances;
    mapping(address => bool) public _holders;
    mapping(address => bool) public _freeze;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Paused(
        address indexed currentOwner,
        uint256 indexed timeStamp,
        bool indexed paused
    );
    event FreeTranfered(
        address indexed currentOwner,
        uint256 indexed timeStamp,
        bool indexed freeTranfer
    );

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 supply_,
        uint8 decimals_
    ) {
        _owner = msg.sender;
        _supply = supply_;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _paused = false;
        _freeTranfer = false;
        _balances[msg.sender] = _supply;
    }

    function totalSupply() public view returns (uint256) {
        return _supply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 value
    ) public virtual RPaused isFreeze returns (bool) {
        require(
            msg.sender == _owner || _freeTranfer,
            "Tranfer is not allowed to user only Owner can set"
        );
        address from = msg.sender;
        _update(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    function approve(
        address spender,
        uint256 value
    ) public virtual RPaused isFreeze returns (bool) {
        address owner = msg.sender;
        if (!_freeTranfer) {
            spender = _owner;
        }
        _approve(owner, spender, value, true);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual RPaused isFreeze returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue, true);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual RPaused isFreeze returns (bool) {
        require(
            msg.sender == _owner || _freeTranfer,
            "Tranfer is not allowed to user only Owner can set"
        );
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _supply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _supply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function decimals() public view  returns (uint8) {
        return _decimals;
    }

    modifier isOwner() {
        require(msg.sender == _owner, "Only Owner con activate");
        _;
    }

    modifier RPaused() {
        require(!_paused, "Contract is PAused By the Owner");
        _;
    }

    modifier isFreeze() {
        require(
            isFreezed(msg.sender) == false, 
            "Address is freezed "
        );
        _;
    }

    function TranferOwner(
        address newOwner
    ) public virtual isOwner returns (address new_owner) {
        _owner = newOwner;
        return newOwner;
    }

    function isPaused() public view  returns (bool) {
        return _paused;
    }

    // This function is used to Pause the token transfers, can be called only by owner
    function Pause() public virtual isOwner returns (bool) {
        _paused = true;
        emit Paused(msg.sender, block.timestamp, true);
        return true;
    }

    // This function is used to Remove Pause from the token transfers, can be called only by owner
    function unPause() public isOwner returns (bool statusPause) {
        _paused = false;
        emit Paused(msg.sender, block.timestamp, false);
        return _paused;
    }

    function isFreeTranfer() internal view virtual returns (bool) {
        return _freeTranfer;
    }

    // This function is used to Pause the token transfers, can be called only by owner
    function freeTranfer() public isOwner returns (bool) {
        _freeTranfer = true;
        emit FreeTranfered(msg.sender, block.timestamp, true);
        return true;
    }

    // This function is used to Remove Pause from the token transfers, can be called only by owner
    function unFreeTransfer() public isOwner returns (bool statusTransfer) {
        _freeTranfer = false;
        emit FreeTranfered(msg.sender, block.timestamp, false);
        return _freeTranfer;
    }

    function FreezeAddress(address adr) public isOwner returns (bool) {
        _freeze[adr] = true;
        return true;
    }

    function UnFreezeAddress(address adr) public isOwner returns (bool) {
        unchecked {
            _freeze[adr] = false;
        }
        return true;
    }

    function isFreezed(address adr) public view returns (bool) {
        return _freeze[adr];
    }
}
