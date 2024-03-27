// SPDX-License-Identifier: Apache-2.0


pragma solidity >=0.8.17 <=0.8.21;
pragma experimental ABIEncoderV2;

import { ISignature } from "./libs/ISignature.sol";

/// @title Digital Signer Licenses,
/// @author Alejandro Pujol, Ivan Ochoa, Guillermo Sanchez.
/// @notice This contract seeks the immutability of the economic licenses
//          practiced by a taxpayer which were issued by a mayor's office.
/// @dev stores data struct (signatureMint) in a format inherited from an interface which allows
//       traceability and license management;
contract LicenseTaxPayer is ISignature {

    mapping(bytes32 => StructSignature) _signatureEnabled;

    mapping(address => bytes32[]) _userSings;

    mapping(address => StructSignature[]) _recordedLicenses;

    mapping(string => address) _taxpayers;

    mapping(address => bool) _admins;

    mapping(address => bool) _propoceAdmins;

    mapping(string => address) _approvers;

    mapping(address owner => uint256) private _balances;

    event eventSignatureCreate(address indexed _addressHolder, bytes32 sing);

    event eventSignatureExpired(address indexed _addressHolder, bytes32 sing);

    event eventNewAdminPropose(address indexed, bool);

    event eventNewAdminRegistred(address indexed, bool);

    event eventNewApprover(address indexed, bool);

    address owner;

    bool private stopMinting = true;

    int32 public totalMinted = 0;

    string private _name;

    string private _symbol;

    constructor(
        string memory name_, string memory symbol_
    ) {
        _admins[msg.sender] = true;
        owner = msg.sender;
        _name = name_;
        _symbol = symbol_;
    }


/// @notice mint, Encrypt and storage a new Licenc.
/// @dev First, it is verified that the taxpayer exists in the taxpayer mapins
//      and that the approver is in the approvers mapins, then a signature is created
//      with the data by parameters such as: _consept, data, identifier through the singLicense
//      function, then a struct in memory, objlisense, which will be verified and finally
//      stored/updated through _checkLicense, the total supply of minted licenses will be increased,
//      the balance of the taxpayer's address will be updated and then the signature will be returned
/// @param _consept: mayoralty(use to sign),
/// @param _owner(use to sign): taxpayer how belong the license,
/// @param _approver(use to sign): personal how aproved in real world the license in sigat,
/// @param  data: string with values internals of economic license(used to sign),
/// @param  identifier: (used to sing) lincese unique value gived by sigat on license aproved
/// @return bytes32 unique by license
    function signatureMint(
        string memory _consept,
        string memory _owner,
        string memory _approver,
        string memory data,
        string memory identifier
    ) public payable isAdmin allowMint returns (bytes32) {
        require(
            taxpayerAddress(_owner) != address(0),
            "Rif Not Registred has Taxpayer"
        );

        require(
            _approvers[_approver] != address(0),
            "Approver Not Registred has Valid"
        );

        require(
            _approvers[_approver] !=  taxpayerAddress(_owner),
            "Approver cannot prove himself"
        );

        bytes32 objSingLicense = singLicense(
            _consept,
            identifier,
            taxpayerAddress(_owner),
            data,
            _approvers[_approver]
        );

        StructSignature memory objlisense = StructSignature(
            _consept,
            identifier,
            taxpayerAddress(_owner),
            data,
            _approvers[_approver],
            objSingLicense,
            true
        );

        _checkLicense(objlisense);
        totalMinted +=1;
        _balances[taxpayerAddress(_owner)] +=1;
        return objlisense.signature;
    }


/// @notice Validates whether a license is valid even if it exists
/// @dev return a bolean values if licence exist in mapping _signatureEnabled where only are a valid licenses
/// @param singnature bytes32 returned by signatureMint function
/// @return bool
    function signatureValidate(
        bytes32 singnature
    ) public view returns (bool) {
        StructSignature memory obj = _signatureEnabled[singnature];
        if (obj.signature == "") {
            return false;
        }
        return true;
    }

/// @notice retrive a data for a store licences minted by singnature
/// @dev returns all stored data from the mining process given a valid byte32 signature
/// @param singnature bytes32, valid
/// @return StructSignature
    function getSignature(
        bytes32 singnature
    ) external view isAdmin returns (StructSignature memory) {
        return _signatureEnabled[singnature];
    }


    // *** deprecated ***
    function getOwnnerSignature(
        bytes32 singnature
    ) external view isAdmin returns (StructSignature memory) {
        return _signatureEnabled[singnature];
    }

    /// @notice returns all licenses from a taxpayer address, only by admins
    /// @dev retrive a array byte32 with all licenses signed by a address taxpayer,
    //       restricted only for admins
    /// @param _owner address
    /// @return Array<byte32>
    function getManyAddressSignature(
        address _owner
    ) external view isAdmin returns (bytes32[] memory) {
        return _userSings[_owner];
    }


    /// @notice returns all licenses from a taxpayer sender, public function
    /// @dev public function to retrive a array byte32 with all licenses signed by a address taxpayer sender
    /// @return Array<byte32>
    function getOwnerAddressSignature() external view returns (bytes32[] memory) {
        return _userSings[msg.sender];
    }


    /// @notice public but only can use the admins return a address by the identifier of taxpayer in real world
    /// @dev retrieve a address stored in mapping by string represent the identifier of taxpayer in real world
    /// @param _rif string
    /// @return address of taxpayer
    function taxpayerAddress(
        string memory _rif
    ) public view isAdmin returns (address) {
        return _taxpayers[_rif];
    }


    /// @notice Einternal function to encrypt data to signature - [only owner]
    /// @dev encode all parameter gived with keccak256 to get a unique value in byte32 how will be a digital sing license
    /// @param _consept: mayoralty(use to sign)
    /// @param _identifier: (used to sing) lincese unique value gived by sigat on license aproved
    /// @param _taxPayer(use to sign): taxpayer how belong the license,
    /// @param _data: string with values internals of economic license(used to sign),
    /// @param _approver(use to sign): personal how aproved in real world the license in sigat,
    /// @return bytes32 value is a digital sign license
    function singLicense(
        string memory _consept,
        string memory _identifier,
        address _taxPayer,
        string memory _data,
        address _approver
    ) private view isAdmin returns (bytes32) {
        return
            keccak256(
                abi.encode(_consept, _identifier, _taxPayer, _data, _approver)
            );
    }
    /// @notice private function in charge to confirm a licence can storage or
    //          delete and then storage a new one depending of identifier
    /// @dev validate if license aready exist in enum creating a struct in memory by the sign,
    //      in case revert the transaction, else, if the identifier exist delete the old one,
    //      in both case new/update will be a storage and emit a new license event
    /// @param _objectLicense memory StructSignature
    /// @return bool
    function _checkLicense(
        StructSignature memory _objectLicense
    ) private isAdmin returns (bool) {
        StructSignature memory objlisense = _signatureEnabled[
            _objectLicense.signature
        ];

        if (objlisense.isEntity == true) {
            revert("License Alredy Exists");
        }

        bytes32[] memory ownersClientLicenses = _userSings[
            _objectLicense.owner
        ];
        for (uint256 i = 0; i < ownersClientLicenses.length; i++) {
            objlisense = _signatureEnabled[ownersClientLicenses[i]];
            if (
                keccak256(bytes(objlisense.identifier)) ==
                keccak256(bytes(_objectLicense.identifier))
            ) {
                _deleteLicense(ownersClientLicenses[i], _objectLicense.owner);
                delete _userSings[_objectLicense.owner][i];
            }
        }

        _createLicense(_objectLicense);

        return true;
    }

    /// @notice Validate a license given data to check if exist or not
    /// @dev Given the same values as mint function this will be encrypt the params and the search by signatureValidate if license exist
    /// @param _consept: mayoralty(use to sign), _
    /// @param _owner(use to sign): taxpayer how belong the license,
    /// @param _approver(use to sign): personal how aproved in real world the license in sigat,
    /// @param data: string with values internals of economic license(used to sign),
    /// @param  identifier: (used to sing) lincese unique value gived by sigat on license aproved
    /// @return bool
    function validateData(
        string memory _consept,
        string memory _owner,
        string memory _approver,
        string memory data,
        string memory identifier
    ) public view isAdmin returns(bool) {
        bytes32 singLicenseObj = singLicense(
            _consept,
            identifier,
            taxpayerAddress(_owner),
            data,
            _approvers[_approver]
        );

        return signatureValidate(singLicenseObj);
    }

    /// @notice storage a license data in contract then emit a new signal with owner and sign, private, only owner can use this function
    /// @dev Storage a struct license in mapping and emit a new  license event with sing and owner
    /// @param _objectLicense StructSignature
    function _createLicense(StructSignature memory _objectLicense) private isAdmin {
        _signatureEnabled[_objectLicense.signature] = _objectLicense;
        _userSings[_objectLicense.owner].push(_objectLicense.signature);
        emit eventSignatureCreate(
            _objectLicense.owner,
            _objectLicense.signature
        );
    }

    /// @notice delete a storaged a license data in contract then emit a delete signal with owner and sign, private, only owner can use this function
    /// @dev delete a existing Storage a struct license in mapping and emit a delete license event with sing and owner
    /// @param sing bytes32, _owner address
    function _deleteLicense(bytes32 sing, address _owner) private isAdmin() {
        delete _signatureEnabled[sing];
        emit eventSignatureExpired(_owner, sing);
    }


    /// @notice declare and mark a license has expired, this mind the license will be delete and resotraged in old's licenses just admins can execute this function
    /// @dev delect a license by _deleteLicense method, decress the owner total balance, delete  license for valid mappings and the  re-storage the old license in _recordedLicenses legacy
    /// @param singnature bytes32
    /// @return bool
    function expirationLicense(
        bytes32 singnature
    ) public payable isAdmin returns (bool) {
        StructSignature memory objlisense = _signatureEnabled[singnature];
        _deleteLicense(singnature, objlisense.owner);
        _balances[objlisense.owner] -=1;
        bytes32[] memory ownersClientLicenses = _userSings[objlisense.owner];
        for (uint256 i = 0; i < ownersClientLicenses.length; i++) {
            if (ownersClientLicenses[i] == singnature) {
                delete _userSings[objlisense.owner][i];
            }
        }
        objlisense.isEntity = false;
        _recordedLicenses[objlisense.owner].push(objlisense);
        return true;
    }

    /// @notice retive a expired license storage in _recordedLicenses
    /// @dev retive a expired license storage in _recordedLicenses validating owner and old signature
    /// @param _owner address, sign byte32
    /// @return oldLicense StructSignature
    function getExpiredLicense(address _owner , bytes32 sign) public payable isAdmin returns (StructSignature memory oldLicense) {
        StructSignature[] memory objLincenses = _recordedLicenses[_owner];
         for (uint256 i = 0; i < objLincenses.length; i++) {
            if (objLincenses[i].signature == sign) {
                return objLincenses[i];
            }
        }
    }

    function addTaxPayer(
        string memory _rif,
        address _relationAddress
    ) public payable isAdmin returns (bool) {
        _taxpayers[_rif] = _relationAddress;
        return true;
    }

    function proposeAdmin(
        address _relationAddress
    ) public payable isAdmin returns (bool) {
        require(
            _propoceAdmins[_relationAddress] != true,
            "address for admin alredy propose"
        );
        _propoceAdmins[_relationAddress] = true;
        emit eventNewAdminPropose(_relationAddress, true);
        return true;
    }

    function approveAdmin(
        address _relationAddress
    ) public payable isAdmin returns (bool) {
        require(
            _propoceAdmins[_relationAddress] == true,
            "address must be registred by admins"
        );
        _admins[_relationAddress] = true;
        delete _propoceAdmins[_relationAddress];
        emit eventNewAdminRegistred(_relationAddress, true);
        return true;
    }

    function addApprover(
        string memory _Id,
        address _relationAddress
    ) public payable isAdmin returns (bool) {
        require(_approvers[_Id] == address(0), "Address already added");
        _approvers[_Id] = _relationAddress;
        emit eventNewApprover(_relationAddress, true);
        return true;
    }

    function tranferOwnership(
        address NewOwner
    ) public payable isAdmin returns (bool) {
        require(NewOwner != address(0), "Owner can't be a Zero address");
        owner = NewOwner;
        return true;
    }

    function mintingStop() public isAdmin returns (bool) {
        stopMinting = !stopMinting;
        return stopMinting;
    }

    function canMint() external view returns (bool) {
        return stopMinting;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only Owner can activate");
        _;
    }

    modifier isAdmin() {
        require(_admins[msg.sender], "Only ADMIN can activate this function");
        _;
    }

    modifier allowMint() {
        require(stopMinting == true, "Minting has stoped by the owner");
        _;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function balance() public view virtual returns (uint256) {
        return _balances[msg.sender];
    }
}
