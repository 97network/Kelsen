pragma solidity >=0.4.22 <0.6.0;


// Standard contract for a presidential election procedure

import "../standardProcedure.sol";
import "../Organ.sol";

contract simpleAdminsAndMasterNominationProcedure is Procedure{

    // 1: Cyclical many to one election (Presidential Election)
    // 2: Cyclical many to many election (Moderators Election)
    // 3: Simple norm nomination 
    // 4: Simple admins and master nomination
    // 5: Vote on Norms 
    // 6: Vote on masters and admins 
    // 7: Cooptation
    int public procedureTypeNumber = 4;
    // address public affectedOrganContract;
    address public authorizedNominatersOrgan;

    // // Storage for procedure name
    // string public procedureName;

    // // Gathering connected organs for easier DAO mapping
    // address[] public linkedOrgans;
    constructor(address _authorizedNominatersOrgan, string _name) 
    public 
    {

    authorizedNominatersOrgan = _authorizedNominatersOrgan;
    linkedOrgans = [authorizedNominatersOrgan];

    // Procedure name 
    procedureName = _name;

    kelsenVersionNumber = 1;
    
    }

    function addAdmin(address _organToReform, address _newAdmin, bool _canAdd, bool _canDelete, bool _canDeposit, bool _canSpend) public returns (bool _success){

        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();

        // Checking that the constitutionnal procedure is a master to the target organ
        Organ organToReformInstance = Organ(_organToReform);
        bool canAdd;
        bool canDelete;
        (canAdd, canDelete) = organToReformInstance.isMaster(address(this));

        
        // Adding an admin if the procedure is allowed
        if (canAdd) {

            organToReformInstance.addAdmin(_newAdmin, _canAdd, _canDelete, _canDeposit, _canSpend);
            _success = true;
        }
        else { _success = false;}

        delete organToReformInstance;

        return _success;

    }
    function remAdmin(address _organToReform, address _oldAdmin) public returns (bool _success){

        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();

        // Checking that the constitutionnal procedure is a master to the target organ
        Organ organToReformInstance = Organ(_organToReform);
        bool canAdd;
        bool canDelete;
        (canAdd, canDelete) = organToReformInstance.isMaster(address(this));

        
        // Removing an admin if the procedure is allowed
        if (canDelete) {

            organToReformInstance.remAdmin(_oldAdmin);
            _success = true;
        }
        else { _success = false;}

        delete organToReformInstance;

        return _success;

    }
    function replaceAdmin(address _organToReform, address _oldAdmin, address _newAdmin, bool _canAdd, bool _canDelete, bool _canDeposit, bool _canSpend) public returns (bool _success){

        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();

        // Checking that the constitutionnal procedure is a master to the target organ
        Organ organToReformInstance = Organ(_organToReform);
        bool canAdd;
        bool canDelete;
        (canAdd, canDelete) = organToReformInstance.isMaster(address(this));

        // Replacing an admin if the procedure is allowed
        if (canAdd && canDelete) {

            organToReformInstance.replaceAdmin(_oldAdmin, _newAdmin, _canAdd, _canDelete, _canDeposit, _canSpend );
            _success = true;
        }
        else { _success = false;}

        delete organToReformInstance;

        return _success;

    }

    function addMaster(address _organToReform, address _newMaster, bool _canAdd, bool _canDelete) public returns (bool _success){

        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();

        // Checking that the constitutionnal procedure is a master to the target organ
        Organ organToReformInstance = Organ(_organToReform);
        bool canAdd;
        bool canDelete;
        (canAdd, canDelete) = organToReformInstance.isMaster(address(this));

        
        // Adding an master if the procedure is allowed
        if (canAdd) {

            organToReformInstance.addMaster(_newMaster, _canAdd, _canDelete);
            _success = true;
        }
        else { _success = false;}

        delete organToReformInstance;

        return _success;

    }
    function remMaster(address _organToReform, address _oldMaster) public returns (bool _success){

        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();
                
        // Checking that the constitutionnal procedure is a master to the target organ
        Organ organToReformInstance = Organ(_organToReform);
        bool canAdd;
        bool canDelete;
        (canAdd, canDelete) = organToReformInstance.isMaster(address(this));

        
        // Removing an master if the procedure is allowed
        if (canDelete) {

            organToReformInstance.remMaster(_oldMaster);
            _success = true;
        }
        else { _success = false;}

        delete organToReformInstance;

        return _success;

    }
    function replaceMaster(address _organToReform, address _oldMaster, address _newMaster, bool _canAdd, bool _canDelete) public returns (bool _success){
        // Checking if caller is an admin
        authorizedNominatersOrgan.isAllowed();
        
        // Checking that the constitutionnal procedure is a master to the target organ
        Organ organToReformInstance = Organ(_organToReform);
        bool canAdd;
        bool canDelete;
        (canAdd, canDelete) = organToReformInstance.isMaster(address(this));

        // Replacing an master if the procedure is allowed
        if (canAdd && canDelete) {

            organToReformInstance.replaceMaster(_oldMaster, _newMaster, _canAdd, _canDelete);
            _success = true;
        }
        else { _success = false;}

        delete organToReformInstance;

        return _success;

    }
    // function getLinkedOrgans() public view returns (address[] _linkedOrgans)
    // {return linkedOrgans;}
    // function getProcedureName() public view returns (string _procedureName)
    // {return procedureName;}

  

}