pragma solidity ^0.4.11;

// Standard contract for a presidential election procedure

import "../standardProcedure.sol";
import "../standardOrgan.sol";
import "../procedures/voteOnAdminsAndMastersProcedure.sol";




contract deployVoteOnAdminsAndMastersProcedure is voteOnAdminsAndMastersProcedure {

function deployVoteOnAdminsAndMastersProcedure (address _votersOrganContract, address _membersWithVetoOrganContract, address _finalPromulgatorsOrganContract, uint _quorumSize, uint _votingPeriodDuration, uint _promulgationPeriodDuration) public {

    votersOrganContract = _votersOrganContract;
    membersWithVetoOrganContract = _membersWithVetoOrganContract;
    finalPromulgatorsOrganContract = _finalPromulgatorsOrganContract; 
    linkedOrgans = [votersOrganContract,membersWithVetoOrganContract,finalPromulgatorsOrganContract];


    quorumSize = _quorumSize;
    // votingPeriodDuration = 3 minutes;
    // promulgationPeriodDuration = 3 minutes;

    votingPeriodDuration = _votingPeriodDuration;
    promulgationPeriodDuration = _promulgationPeriodDuration;

    kelsenVersionNumber = 1;

    }
}
