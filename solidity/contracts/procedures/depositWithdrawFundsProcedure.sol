pragma solidity ^0.4.11;

// Standard contract for promulgation of a norm

import "../standardProcedure.sol";
import "../standardOrgan.sol";


contract depositWithdrawFundsProcedure is Procedure{
    // 1: Cyclical many to one election (Presidential Election)
    // 2: Cyclical many to many election (Moderators Election)
    // 3: Simple norm nomination 
    // 4: Simple admins and master nomination
    // 5: Vote on Norms 
    // 6: Vote on masters and admins 
    // 7: Cooptation
    // 8: Vote on an expense
    // 9: Deposit/Withdraw funds on an organ
    // 10: General Assembly
    int public procedureTypeNumber = 9;

    // // Storage for procedure name
    // string public procedureName;

    // // Gathering connected organs for easier DAO mapping
    // address[] public linkedOrgans;

    // Where are authorized depositors registered. If authorizedDepositorsOrganContract is set to 0, anyone can deposit funds
    address public authorizedDepositorsOrganContract;

    // Where are authorized depositors registered. If authorizedDepositorsOrganContract is set to 0, anyone can deposit funds
    address public authorizedWithdrawersOrganContract;

    // Default organ to which deposits are sent
    address public defaultReceivingOrganContract;



    // Mapping each proposition to the user creating it
    mapping (address => uint) public amountDepositedByDepositorAddress;    
    mapping (address => uint) public amountWithdrawnByDepositorAddress;   

    // Mapping each proposition to the user who participated
    mapping (address => uint) public amountDepositedToReceiverAddress;
    mapping (address => uint) public amountWithdrawnFromReceiverAddress;

    // Events
    event depositedFunds(address _from, address _payoutAddress, uint _amount);
    event withdrewFunds(address _from, address _payoutAddress, uint _amount);

    function () public payable {

        

        // Checking if depositors are restricted
        if (authorizedDepositorsOrganContract != 0x0000) {
            // Instanciating Organ
            Organ authorizedDepositorsOrgan = Organ(authorizedDepositorsOrganContract);
            require(authorizedDepositorsOrgan.isNorm(msg.sender));
            delete authorizedDepositorsOrgan;
        }

        

        // Sending funds to organ
        defaultReceivingOrganContract.transfer(msg.value);

        // Recording value transfer
        amountDepositedByDepositorAddress[msg.sender] += msg.value;
        amountDepositedToReceiverAddress[defaultReceivingOrganContract] += msg.value;

        // Log event
        depositedFunds(msg.sender, defaultReceivingOrganContract, msg.value);


    }

    function depositToOrgan(address _targetOrgan) public payable {

        // Instanciating Organ
        Organ authorizedDepositorsOrgan = Organ(authorizedDepositorsOrganContract);

        // Checking if depositors are restricted
        if (authorizedDepositorsOrganContract != 0x0000) {

            require(authorizedDepositorsOrgan.isNorm(msg.sender));
            
        }

        delete authorizedDepositorsOrgan;

        // Sending funds to organ
        _targetOrgan.transfer(msg.value);

        // Recording value transfer
        amountDepositedByDepositorAddress[msg.sender] += msg.value;
        amountDepositedToReceiverAddress[_targetOrgan] += msg.value;

        // Log event
        depositedFunds(msg.sender, _targetOrgan, msg.value);


    }

    function withdrawOnOrgan(address _targetOrgan, address _receiver, uint _amount) public {

        // Instanciating Organ
        Organ authorizedWithdrawersOrgan = Organ(authorizedWithdrawersOrganContract);

        // Checking if withdrawers are restricted
		require(authorizedWithdrawersOrgan.isNorm(msg.sender));
            
   
        delete authorizedWithdrawersOrgan;

        // Instanciating target organ for withdrawal
        Organ organToWithdrawFrom = Organ(_targetOrgan);

        // Withdrawing funds from organ
        organToWithdrawFrom.payout(_receiver, _amount);

        // Recording value transfer
        amountWithdrawnFromReceiverAddress[msg.sender] += _amount;
        amountWithdrawnByDepositorAddress[_targetOrgan] += _amount;

        // Log event
        withdrewFunds( _targetOrgan, msg.sender, _amount);


    }

    function getFundsDepositedByUser(address _userAddress) public view returns (uint)
    {return amountDepositedByDepositorAddress[_userAddress];}    
    function getFundsDepositedToOrgan(address _organAddress) public view returns (uint)
    {return amountDepositedToReceiverAddress[_organAddress];} 
    function getFundsWithdrawnByUser(address _userAddress) public view returns (uint)
    {return amountWithdrawnFromReceiverAddress[_userAddress];}    
    function getFundsWithdrawnFromOrgan(address _organAddress) public view returns (uint)
    {return amountWithdrawnByDepositorAddress[_organAddress];} 
    // function getLinkedOrgans() public view returns (address[] _linkedOrgans)
    // {return linkedOrgans;}
    // function getProcedureName() public view returns (string _procedureName)
    // {return procedureName;}

}

