pragma solidity >=0.8.4 <=0.8.7;
pragma experimental ABIEncoderV2;

contract Licencias {


    struct StructLicencia {
        string alcaldia;
        string rif;
        string numero;
        string uuid;
        string tipo;
        uint renoDate;
        uint expDate;
        string activitis;
        }

    event licencia(address indexed _addressHolder, StructLicencia data);

    mapping(address => StructLicencia) _recordedLicenses;

    StructLicencia objlisense;

    function createLicencia(
        address _holder, string calldata _alcaldia, string calldata _rif,
        string calldata _numero, string calldata _uuid, string calldata _tipo, uint _renoDate,
        uint _expDate,
        string calldata _activitis) public payable {

           objlisense = StructLicencia(
            _alcaldia,
            _rif,
            _numero,
            _uuid,
            _tipo,
            _renoDate,
            _expDate,
            _activitis
        );

        createContracLicense(_holder, objlisense);

        emit licencia(
            msg.sender,
           objlisense);
    }


    function createContracLicense(address _holder, StructLicencia memory _val) private {
        _recordedLicenses[_holder] = _val;
    }


    function getLicense(address _holder)public view returns(StructLicencia memory) {
        return _recordedLicenses[_holder];
    }

}