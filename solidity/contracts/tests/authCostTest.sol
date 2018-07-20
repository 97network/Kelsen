pragma solidity ^0.4.11;

/// @title Authentication cost test


import "../Kelsen.sol";
import "../standardOrgan.sol";



contract authCostTest {

    address public owner;
    address public referenceOrgan;

    function authCostTest(address _referenceOrgan) public {
        owner = msg.sender;
        referenceOrgan = _referenceOrgan;

        }

    function noAuth() public pure returns (uint) {
        return 4;

        }
    function  authWithOwner() public view returns (uint) {
        require(msg.sender == owner);
        return 4;

        }

    function  authWithOrgan() public view returns (uint) {
        Organ referenceOrganInstance = Organ(referenceOrgan);
        require(referenceOrganInstance.isNorm(msg.sender));
        delete referenceOrganInstance;

        return 4;

        }



}

