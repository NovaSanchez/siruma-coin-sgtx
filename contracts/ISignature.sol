pragma solidity ^0.8.17;

interface ISignature {

    struct StructSignature {
        string concept;
        string identifier;
        address owner;
        string data;
        address aprrover;
        bytes32 signature;
        bool isEntity;
    }

    function signatureMint(
        string calldata _consept,
        string calldata _owner,
        string calldata _approver,
        string calldata data,
        string calldata identifier
    ) external payable returns (bytes32);


    function signatureValidate(bytes32 singnature) external view returns (bool);

    function getAddressSignature(bytes32 singnature) external view returns (StructSignature memory);

    function getManyAddressSignature(address taxpayer) external view returns (bytes32[] memory);

}