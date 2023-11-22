// SPDX-License-Identifier: MIT

pragma solidity >=0.8.17 <=0.8.21;
pragma experimental ABIEncoderV2;

import {ISignature} from "./ISignature.sol";

contract LicenseTaxPayer is ISignature {

    mapping(bytes32 => StructSignature) _signatureEnabled;

    mapping(address => bytes32[]) _userSings;

    mapping(address => StructSignature[]) _recordedLicenses;

    mapping(string => address) _taxpayers;

    mapping(address => bool) _admins;

    mapping(string => address) _approvers;

    event eventSignatureCreate(address indexed _addressHolder, bytes32 sing);

    event eventSignatureExpired(address indexed _addressHolder, bytes32 sing);

    address owner;

    constructor() {
        _admins[msg.sender] = true;
        owner = msg.sender;
    }

    function signatureMint(
        string memory _consept,
        string memory _owner,
        string memory _approver,
        string memory data,
        string memory identifier
    ) public payable isOwner returns (bytes32) {

        require(taxpayerAddress(_owner) != address(0), "Rif Not Registred has Taxpayer");

        require( _approvers[_approver] != address(0), "Approver Not Registred has Valid");

        bytes32 singLicense = singLicense(
            _consept,
            identifier,
            taxpayerAddress(_owner),
            data,
            _approvers[_approver]);

        StructSignature memory objlisense = StructSignature(
            _consept,
            identifier,
            taxpayerAddress(_owner),
            data,
             _approvers[_approver],
            singLicense,
            true
        );

        _checkLicense(objlisense);

        return objlisense.signature;
    }


    function signatureValidate(bytes32 singnature)
        external
        view
        returns (bool)
    {
        StructSignature memory obj = _signatureEnabled[singnature];
        if (obj.signature == "") {
            return false;
        }
        return true;
    }

    function getAddressSignature(bytes32 singnature)
        external
        view
        isAdmin
        returns (StructSignature memory)
    {
        return _signatureEnabled[singnature];
    }

    function getManyAddressSignature(address taxpayer)
        external
        view
        returns (bytes32[] memory)
    {
        return _userSings[taxpayer];
    }

    function taxpayerAddress(string memory _rif)
        public
        view
        isAdmin
        returns (address)
    {
        return _taxpayers[_rif];
    }

    function singLicense(
        string memory _consept,
        string memory _identifier,
        address _taxPayer,
        string memory _data,
        address _aprrover
    ) private pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _consept,
                    _identifier,
                    _taxPayer,
                    _data,
                    _aprrover
                )
            );
    }

   function _checkLicense(StructSignature memory _objectLicense) private isOwner returns(bool) {

        StructSignature memory objlisense = _signatureEnabled[_objectLicense.signature];

        if(objlisense.isEntity == true) {
            revert('License Alredy Exists');
        }

        bytes32[] memory ownersClientLicenses = _userSings[_objectLicense.owner];
        for (uint256 i = 0; i < ownersClientLicenses.length; i++) {
            objlisense = _signatureEnabled[ownersClientLicenses[i]];
            if(keccak256(bytes(objlisense.identifier)) == keccak256(bytes(_objectLicense.identifier)) ) {
                _deleteLicense(ownersClientLicenses[i], _objectLicense.owner);
                delete _userSings[_objectLicense.owner][i];
            }
        }

        _createLicense(_objectLicense);

        return true;
    }


   function _createLicense(StructSignature memory _objectLicense) private {
        _signatureEnabled[_objectLicense.signature] = _objectLicense;
        _userSings[_objectLicense.owner].push(_objectLicense.signature);
        emit eventSignatureCreate(_objectLicense.owner, _objectLicense.signature);
    }

   function _deleteLicense(bytes32 sing, address _owner  ) private {
        delete _signatureEnabled[sing];
        emit eventSignatureExpired(_owner, sing);
    }

    function expirationLicense(bytes32 singnature) public isAdmin returns (bool) {
        StructSignature memory objlisense = _signatureEnabled[singnature];
        _deleteLicense(singnature, objlisense.owner);
        bytes32[] memory ownersClientLicenses = _userSings[objlisense.owner];
        for (uint256 i = 0; i < ownersClientLicenses.length; i++) {
            if(ownersClientLicenses[i] == singnature) {
                delete _userSings[objlisense.owner][i];
            }
        }
        return true;
    }

    function addTaxPayer(string memory _rif, address _relationAddress) public isOwner returns (bool) {
        _taxpayers[_rif] = _relationAddress;
        return true;
    }

    function addApprovers(string memory _Id, address _relationAddress) public isOwner returns (bool) {
        _approvers[_Id] = _relationAddress;
        return true;
    }

    function tranferOwnership(address NewOwner) public payable isOwner returns(bool) {
        require(NewOwner != address(0), "Owner can't be a Zero address");
        owner = NewOwner;
        return true;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only Owner can activate");
        _;
    }

    modifier isAdmin() {
        require(_admins[msg.sender]);
        _;
    }
}
