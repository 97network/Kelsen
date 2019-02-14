pragma solidity >=0.4.22 <0.6.0;

// Standard contract for a presidential election procedure

import "../standardProcedure.sol";
import "../Organ.sol";

contract simpleNormNominationProcedure is Procedure{

    // 1: Cyclical many to one election (Presidential Election)
    // 2: Cyclical many to many election (Moderators Election)
    // 3: Simple norm nomination 
    // 4: Simple admins and master nomination
    // 5: Vote on Norms 
    // 6: Vote on masters and admins 
    // 7: Cooptation

    // address public affectedOrganContract;
    address public authorizedNominatersOrgan;

    constructor (address _authorizedNominatersOrgan, string _name) 
    public
    {
    authorizedNominatersOrgan = _authorizedNominatersOrgan;
    procedureInfo.procedureName = _name;
    procedureInfo.procedureTypeNumber = 3;
    procedureInfo.linkedOrgans = [authorizedNominatersOrgan];
    }

    function addNorm(address _targetOrgan, address _normAdress, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size)  
    public 
    returns (uint newNormNumber) 
    {
        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();

        // Sending the addNorm command to the desired organ. If the nomination procedure is not an admin, the call will fail
        Organ targetOrganInstance = Organ(_targetOrgan);
        return targetOrganInstance.addNorm(_normAdress, _ipfsHash, _hash_function, _size);
    }

    function remNorm(address _targetOrgan, uint _normNumber) 
    public 
    {
        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();

        // Sending the addNorm command to the desired organ. If the nomination procedure is not an admin, the call will fail
        Organ targetOrganInstance = Organ(_targetOrgan);
        targetOrganInstance.remNorm(_normNumber);
    }

    function replaceNorm(address _targetOrgan, uint _oldNormNumber, address _newNormAdress, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size) 
    public 
    {
        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();

        // Sending the replaceNorm command to the desired organ. If the nomination procedure is not an admin, the call will fail
        Organ targetOrganInstance = Organ(_targetOrgan);
        targetOrganInstance.replaceNorm(_oldNormNumber, _newNormAdress, _ipfsHash, _hash_function, _size);        
    }
}