pragma solidity >=0.8.17 <=0.8.21;
pragma experimental ABIEncoderV2;

contract Licencias {
    constructor() {
        _owners[msg.sender] = true;
        owner = msg.sender;
    }
    struct StructLicencia {
        string alcaldia;
        string rif;
        uint renoDate;
        uint expDate;
        string activitis;
        bytes32 firma;
    }

    event licencia(address indexed _addressHolder, StructLicencia data);

    mapping(address => mapping(string => StructLicencia)) _recordedLicenses;

    mapping(address => string[]) _userLicenses;

    mapping(address => bytes32[]) _userSings;

    mapping(address => bool) _owners;

    mapping(string => address) _taxpayers;

    address owner;

    StructLicencia objlisense;

    function createLicencia(
        string calldata _alcaldia,
        string calldata _rif,
        uint _renoDate,
        uint _expDate,
        string calldata _activitis,
        string memory license
    ) public payable isSomeOwner returns (bytes32){

        address _holder = taxpayerAddress(_rif);

        if(_holder == address(0)) {
            revert('Rif Not Registred has Taxpayer');
        }

        bytes32 singLicense = singLicense(
            _holder,
            license,
            _activitis,
            _expDate
        );

        objlisense = StructLicencia(
            _alcaldia,
            _rif,
            _renoDate,
            _expDate,
            _activitis,
            singLicense
        );

        _createUpdateContracLicense(_holder, license, objlisense);

        string[] memory userLicenses = getUserLicences(_holder);

        if (userLicenses.length == 0) {
            _loadLicenseAnUser(_holder, license);
        }
        _loadLicenseHashUserArray(_holder, objlisense.firma);

        return objlisense.firma;
    }

    function _createUpdateContracLicense (
        address _holder,
        string memory licence,
        StructLicencia memory _val
    ) private {
        _recordedLicenses[_holder][licence] = _val;
        emit licencia(msg.sender, objlisense);
    }

    function _loadLicenseAnUser(
        address _holder,
        string memory licence
    ) private {
        _userLicenses[_holder].push(licence);
    }

    function _loadLicenseHashUserArray(
        address _holder,
        bytes32 sing
    ) private {
        _userSings[_holder].push(sing);
    }

    function getUserLicences(
        address _holder
    ) public view returns (string[] memory) {
        return _userLicenses[_holder];
    }

    function getLicenseLicence(
        address _holder,
        string memory license
    ) public view returns (StructLicencia memory) {
        return _recordedLicenses[_holder][license];
    }

    function singLicense(
        address _holder,
        string memory license,
        string memory activities,
        uint expirationDate
    ) private returns (bytes32) {
        return
            keccak256(abi.encode(_holder, license, activities, expirationDate));
    }

    // function getAddressSings(address sub) public view isSomeOwner(string[] memory) {
    //     return _userSings[sub];
    // }

    function validLicence(address sub, bytes32 sing) public view returns(bool) {
        bytes32[] memory userSings = _userSings[sub];
        for (uint256 i = 0; i < userSings.length; i++) {
            if(userSings[i] == sing) {
                return true;
            }
        }
        return false;
    }

    function addOwners(address subject) public payable isOwner{
        _owners[subject] = true;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only Owner con activate");
        _;
    }

    modifier isSomeOwner() {
        require(_owners[msg.sender] == true, "Only Owner con activate");
        _;
    }

    function taxpayerAddress(string memory _rif) public view returns (address) {
        return _taxpayers[_rif];
    }

    function validTaxPayer(string memory _rif) private returns (bool) {
        address valid = taxpayerAddress(_rif);
        if(valid == address(0)) {
            return false;
        }
    }
    function addTaxPayer(string memory _rif, address _relationAddress) public isOwner returns (bool) {
        _taxpayers[_rif] = _relationAddress;
        return true;
    }

}
