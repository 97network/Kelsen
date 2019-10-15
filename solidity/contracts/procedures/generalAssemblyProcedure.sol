pragma solidity ^0.4.11;

// Standard contract for promulgation of a norm

import "../standardProcedure.sol";
import "../standardOrgan.sol";
import "./voteOnAdminsAndMastersProcedure.sol";


contract generalAssemblyProcedure is Procedure{
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
    int public procedureTypeNumber = 10;


    // First stakeholder address is presidentOrganContract
    // Second stakeholder address is propositionVotingProcedure
    // procedureLibrary.twoRegisteredOrgans public linkedOrgans;
    // propositionVotingLibrary.VotingProcessInfo public votingProcedureInfo;

    // Specific procedure variables
    bool public isAssemblyOpenedForProposition;
    uint public lastStartedAssembly;
    uint public normalAssemblyDelay;
    uint public timeToPropose;
    address public propositionVotingProcedure;
    address public presidentOrganContract;

    // ######################

    constructor(address _presidentOrganContract, address _propositionVotingProcedure, uint _normalAssemblyDelay, uint _timeToPropose, string _name) 
    public 
    {
    // procedureInfo.initProcedure(8, _name, 2);
    // linkedOrgans.initTwoRegisteredOrgans(presidentOrganContract, propositionVotingProcedure);
    timeToPropose = _timeToPropose;
    normalAssemblyDelay = _normalAssemblyDelay;
    presidentOrganContract = _presidentOrganContract;
    propositionVotingProcedure = _propositionVotingProcedure;

    linkedOrgans = [_presidentOrganContract];

    // Procedure name 
    procedureName = _name;

    // votingPeriodDuration = 3 minutes;
    // promulgationPeriodDuration = 3 minutes;


    kelsenVersionNumber = 1;

    }

    function startAssembly()
    public
    {
        require(!isAssemblyOpenedForProposition);
        if (lastStartedAssembly + normalAssemblyDelay > now)
        {
            // procedureLibrary.isAllowed(linkedOrgans.firstOrganAddress);
            // Checking if caller is an admin
            Organ presidentOrganInstance = Organ(presidentOrganContract);
            require(presidentOrganInstance.isNorm(msg.sender));
            delete presidentOrganInstance;
        }
        
        isAssemblyOpenedForProposition = true;
        lastStartedAssembly = now;
    }

    function addOrdreDuJour(address _targetOrgan, address _contractToAdd, address _contractToRemove, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size, string _name, bool _canAdd, bool _canDelete, bool _canDeposit, bool _canSpend, uint _propositionType)
    public
    {
        require(isAssemblyOpenedForProposition);
        // procedureLibrary.isAllowed(linkedOrgans.firstOrganAddress);
        Organ presidentOrganInstance = Organ(presidentOrganContract);
        require(presidentOrganInstance.isNorm(msg.sender));
        delete presidentOrganInstance;
        // Instanciating the proposition adding procedure
        voteOnAdminsAndMastersProcedure propositionProcedure = voteOnAdminsAndMastersProcedure(propositionVotingProcedure);
        propositionProcedure.createProposition(_targetOrgan, _contractToAdd, _contractToRemove, _ipfsHash, _hash_function, _size, _name , _canAdd, _canDelete, _canDeposit, _canSpend, _propositionType);
    }

    function endAssembly()
    public
    {
        require(lastStartedAssembly + timeToPropose < now);

        isAssemblyOpenedForProposition = false;
        lastStartedAssembly = now;
    }

    // /// Create a new ballot to choose one of `proposalNames`.
    // function createProposition(address payable _targetOrgan, address payable _contractToAdd, address payable _contractToRemove, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size, bool _canAdd, bool _canDelete, bool _canDeposit, bool _canSpend, uint _propositionType) 
    // public 
    // returns (uint propositionNumber)
    // {
    //     // Check the proposition creator is able to make a proposition
    //     procedureLibrary.isAllowed(linkedOrgans.firstOrganAddress);

    //     return votingProcedureInfo.createPropositionLib(_targetOrgan, _contractToAdd, _contractToRemove, _ipfsHash, _hash_function, _size, _canAdd, _canDelete, _canDeposit, _canSpend, _propositionType);
    // }

    // /// Vote for a proposition
    // function vote(uint _propositionNumber, bool _acceptProposition) 
    // public 
    // {
    //     // Check the voter is able to vote on a proposition
    //     procedureLibrary.isAllowed(linkedOrgans.firstOrganAddress);

    //     votingProcedureInfo.voteLib(votingProcedureInfo.propositions[_propositionNumber], _acceptProposition);
    // }

    //     /// Vote for a candidate
    // function veto(uint _propositionNumber) 
    // public 
    // {

    //     // Check the voter is able to veto the proposition
    //     procedureLibrary.isAllowed(linkedOrgans.secondOrganAddress);
        
    //     votingProcedureInfo.propositions[_propositionNumber].vetoLib();
    // }

    // // The vote is finished and we close it. This triggers the outcome of the vote.

    // function endPropositionVote(uint _propositionNumber) 
    // public 
    // returns (bool hasBeenAccepted) 
    // {

    //     return votingProcedureInfo.endPropositionVoteLib(votingProcedureInfo.propositions[_propositionNumber], linkedOrgans.firstOrganAddress);
    // }

    // function promulgateProposition(uint _propositionNumber, bool _promulgate) 
    // public 
    // {
    //     // If promulgation is happening before endOfVote + promulgationPeriodDuration, check caller is an official promulgator
    //     if (now < votingProcedureInfo.propositions[_propositionNumber].votingPeriodEndDate + votingProcedureInfo.promulgationPeriodDuration)
    //     {        
    //         // Check the voter is able to promulgate the proposition
    //         procedureLibrary.isAllowed(linkedOrgans.thirdOrganAddress);
    //     }
    //     else 
    //     { 
    //         // If Promulgator did not promulgate, the only option is validating
    //         require(_promulgate);
    //     }

    //     votingProcedureInfo.propositions[_propositionNumber].promulgatePropositionLib(_promulgate);
    // }

    // function archiveDefunctProposition(uint _propositionNumber) 
    // public 
    // {
    // // If a proposition contains an instruction that can not be executed (eg "add an admin" without having canAdd enabled), this proposition can be closed
    //     votingProcedureInfo.propositions[_propositionNumber].archiveDefunctPropositionLib();
    // }


    // //////////////////////// Functions to communicate with other contracts

    // function haveIVoted(uint _propositionNumber) 
    // public 
    // view 
    // returns (bool IHaveVoted)
    // {
    //     return propositionVotingLibrary.getBoolean(votingProcedureInfo.userParticipation[msg.sender], _propositionNumber);
    // }

    // function getPropositionDocumentation(uint _propositionNumber) 
    // public
    // view
    // returns (bytes32 ipfsHash, uint8 hash_function, uint8 size, uint propositionType)
    // {
    //     return (votingProcedureInfo.propositions[_propositionNumber].ipfsHash, votingProcedureInfo.propositions[_propositionNumber].hash_function, votingProcedureInfo.propositions[_propositionNumber].size, votingProcedureInfo.propositions[_propositionNumber].propositionType);
    // }

    // function getPropositionStatus(uint _propositionNumber) 
    // public
    // view
    // returns ( bool wasVetoed, bool wasCounted, bool wasAccepted, bool wasEnded, uint votingPeriodEndDate)
    // {
    //     return (votingProcedureInfo.propositions[_propositionNumber].wasVetoed, votingProcedureInfo.propositions[_propositionNumber].wasCounted, votingProcedureInfo.propositions[_propositionNumber].wasAccepted, votingProcedureInfo.propositions[_propositionNumber].wasEnded, votingProcedureInfo.propositions[_propositionNumber].votingPeriodEndDate);
    // }

    // function getPropositionStatistics(uint _propositionNumber) 
    // public
    // view
    // returns (uint voteFor, uint totalVoteCount)
    // {
    //     require(votingProcedureInfo.propositions[_propositionNumber].votingPeriodEndDate < now);
    //     return (votingProcedureInfo.propositions[_propositionNumber].voteFor, votingProcedureInfo.propositions[_propositionNumber].totalVoteCount);
    // }

    // function getPropositionAddresses(uint _propositionNumber) 
    // public
    // view
    // returns (address targetOrgan, address contractToAdd, address contractToRemove)
    // {
    //     return (votingProcedureInfo.propositions[_propositionNumber].targetOrgan, votingProcedureInfo.propositions[_propositionNumber].contractToAdd, votingProcedureInfo.propositions[_propositionNumber].contractToRemove);
    // }

    // function getPropositionPermissions(uint _propositionNumber) 
    // public
    // view
    // returns (bool canAdd, bool canDelete, bool canSpend, bool canDeposit)
    // {
    //     return (votingProcedureInfo.propositions[_propositionNumber].canAdd, votingProcedureInfo.propositions[_propositionNumber].canDelete, votingProcedureInfo.propositions[_propositionNumber].canSpend, votingProcedureInfo.propositions[_propositionNumber].canDeposit);
    // }



}

