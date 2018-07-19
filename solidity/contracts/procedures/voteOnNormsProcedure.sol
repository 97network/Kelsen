pragma solidity ^0.4.11;

// Standard contract for promulgation of a norm

import "../standardProcedure.sol";
import "../standardOrgan.sol";


contract voteOnNormsProcedure is Procedure{
    // 1: Cyclical many to one election (Presidential Election)
    // 2: Cyclical many to many election (Moderators Election)
    // 3: Simple norm nomination 
    // 4: Simple admins and master nomination
    // 5: Vote on Norms 
    // 6: Vote on masters and admins 
    // 7: Cooptation
    int public procedureTypeNumber = 5;


    // ############## Variable to set up when declaring the procedure

    // Which organ will be affected
    address public affectedOrganContract;

    // Organ in which the voters are registered
    address public votersOrganContract;

    // Organ in which the voters with veto power are registered
    address public membersWithVetoOrganContract;

    // Organ in which final promulgators are listed
    address public finalPromulgatorsOrganContract;

    // Minimum participation to validate election. This is a percentage value; for 40% quorum, quorumSize = 40
    uint public quorumSize;

    // Time for participant to vote
    uint public votingPeriodDuration;

    // Time for president to promulgat
    uint public promulgationPeriodDuration;

    // Minimum proportion of votes to win election. This is a percentage value; for 50% majority, majoritySize = 50
    uint public majoritySize;

    // // Storage for procedure name
    // string public procedureName;

    // ########################

    // Variable of the procedure to keep track of propositions
    uint public totalPropositionNumber;


    // Proposition structure
    struct Proposition {

        // Proposition details
        address contractToAdd;
        uint contractToRemoveId;
        bytes32 ipfsHash; // ID of proposal on IPFS
        uint8 hash_function;
        uint8 size;
        string name;

        // **** Voting variables
        // Mapping to track user votes
        mapping(address => bool) hasUserVoted;
        uint startDate;
        uint votingPeriodEndDate;
        bool wasVetoed;
        bool wasCounted;
        bool wasAccepted;
        bool wasEnded;
        uint voteFor;
        // uint voteAgainst;
        uint totalVoteCount;
    }



    // A dynamically-sized array of `Proposition` structs.
    Proposition[] propositions;

    // Dynamic size array of status of propositions
    bool[] public propositionsWaitingEndOfVote;
    bool[] public propositionsWaitingPromulgation;

    // Mapping each proposition to the user creating it
    mapping (address => uint[]) public propositionToUser;    

    // Mapping each proposition to the user who participated
    mapping (address => uint[]) public propositionToVoter;

    // Mapping each proposition to the user vetoing it
    mapping (address => uint[]) public propositionToVetoer;

    // Mapping each proposition to the user promulgating it
    mapping (address => uint[]) public propositionToPromulgator;

    

    // Events
    event createPropositionEvent(address _from, address _contractToAdd, uint _contractToRemoveId, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size);
    event voteOnProposition(address _from, uint _propositionNumber);
    event vetoProposition(address _from, uint _propositionNumber);
    event countVotes(address _from, uint _propositionNumber);
    event promulgatePropositionEvent(address _from, uint _propositionNumber, bool _promulgate);

    /// Create a new ballot to choose one of `proposalNames`.
    function createProposition(address _contractToAdd, uint _contractToRemoveId, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size, string _name) public returns (uint propositionNumber){

            // Check the proposition creator is able to make a proposition
            Organ voterRegistryOrgan = Organ(votersOrganContract);
            require(voterRegistryOrgan.isNorm(msg.sender));
            delete voterRegistryOrgan;

            // Retrieving proposition details
            Proposition memory newProposition;
            newProposition.contractToAdd = _contractToAdd;
            newProposition.contractToRemoveId = _contractToRemoveId;
            newProposition.ipfsHash = _ipfsHash;
            newProposition.hash_function = _hash_function;
            newProposition.size = _size;
            newProposition.name = _name;

            // Instanciating proposition

            newProposition.startDate = now;
            newProposition.votingPeriodEndDate = now + votingPeriodDuration;            
            newProposition.wasVetoed = false;
            newProposition.wasEnded = false;
            newProposition.wasCounted = false;
            newProposition.wasAccepted = false;
            newProposition.totalVoteCount = 0;
            newProposition.voteFor = 0;
            // newProposition.voteAgainst = 0;
            propositions.push(newProposition);
            delete newProposition;

            propositionNumber = propositions.length - 1;

            // Tracking proposition being deposed
            totalPropositionNumber += 1;
            propositionToUser[msg.sender].push(propositionNumber);
            propositionsWaitingEndOfVote.push(true);
            propositionsWaitingPromulgation.push(false);

            // proposition creation event
            createPropositionEvent(msg.sender, _contractToAdd, _contractToRemoveId, _ipfsHash, _hash_function, _size);

    }

    /// Vote for a proposition
    function vote(uint _propositionNumber, bool _acceptProposition) public {
        // Check the voter is able to vote on a proposition
        Organ voterRegistryOrgan = Organ(votersOrganContract);
        require(voterRegistryOrgan.isNorm(msg.sender));
        delete voterRegistryOrgan;
        
        // Check if voter already voted
        require(!propositions[_propositionNumber].hasUserVoted[msg.sender]);

        // Check if vote is still active
        require(!propositions[_propositionNumber].wasCounted);

        // Check if voting period ended
        require(propositions[_propositionNumber].votingPeriodEndDate > now);

        // Adding vote
        if(_acceptProposition == true)
        {propositions[_propositionNumber].voteFor += 1;}

        // Loggin that user voted
        propositions[_propositionNumber].hasUserVoted[msg.sender] = true;
        
        // Adding vote count
        propositions[_propositionNumber].totalVoteCount += 1;

        // Logging that user voted
        propositionToVoter[msg.sender].push(_propositionNumber);

        // create vote event
        voteOnProposition(msg.sender, _propositionNumber);
    }

        /// Vote for a candidate
    function veto(uint _propositionNumber) public {

        // Check the voter is able to veto the proposition
        Organ membersWithVetoOrgan = Organ(membersWithVetoOrganContract);
        require(membersWithVetoOrgan.isNorm(msg.sender));
        delete membersWithVetoOrgan;
        
        // Check if vote is still active
        require(!propositions[_propositionNumber].wasCounted);

        // Check if voting period ended
        require(propositions[_propositionNumber].votingPeriodEndDate > now);

        // Log that proposition was vetoed
        propositions[_propositionNumber].wasVetoed = true;

        // Log that user vetoed this proposition
        propositionToVetoer[msg.sender].push(_propositionNumber);

        //  Create veto event
        vetoProposition(msg.sender, _propositionNumber);

    }

    // The vote is finished and we close it. This triggers the outcome of the vote.

    function endPropositionVote(uint _propositionNumber) public returns (bool hasBeenAccepted) {
        // We check if the vote was already counted
        require(!propositions[_propositionNumber].wasCounted);

        // Checking that the vote can be closed
        require(propositions[_propositionNumber].votingPeriodEndDate < now);

        Organ voterRegistryOrgan = Organ(votersOrganContract);

        // We check that Quorum was obtained and that a majority of votes were cast in favor of the proposition
        if (propositions[_propositionNumber].wasVetoed )
            {hasBeenAccepted=false;
                propositions[_propositionNumber].wasEnded = true;}
        else if
            ((propositions[_propositionNumber].totalVoteCount*100 >= quorumSize*voterRegistryOrgan.getActiveNormNumber()) && (propositions[_propositionNumber].voteFor*100 > propositions[_propositionNumber].totalVoteCount*majoritySize))
            {hasBeenAccepted = true;}
        else 
            {hasBeenAccepted=false;
            propositions[_propositionNumber].wasEnded = true;}


        // ############## Updating ballot values if vote concluded
        propositions[_propositionNumber].wasCounted = true;
        propositions[_propositionNumber].wasAccepted = hasBeenAccepted;
        propositionsWaitingEndOfVote[_propositionNumber] = false;
        propositionsWaitingPromulgation[_propositionNumber] = true;

        countVotes(msg.sender, _propositionNumber);
    }
    function promulgateProposition(uint _propositionNumber, bool _promulgate) public
    {
        // Checking if ballot was already enforced
        require(!propositions[_propositionNumber].wasEnded );

        // Checking the ballot was counted
        require(propositions[_propositionNumber].wasCounted);

        // If promulgation is happening before endOfVote + promulgationPeriodDuration, check caller is an official promulgator
        if (now < propositions[_propositionNumber].votingPeriodEndDate + promulgationPeriodDuration)
            {        // Check the voter is able to promulgate the proposition
            Organ promulgatorsOrgan = Organ(finalPromulgatorsOrganContract);
            require(promulgatorsOrgan.isNorm(msg.sender));
            delete promulgatorsOrgan;
            }
        else { // If Promulgator did not promulgate, the only option is validating
            require(_promulgate);
            }

        // Checking the ballot was accepted
        require(propositions[_propositionNumber].wasAccepted);

        if ((!_promulgate)||((propositions[_propositionNumber].contractToAdd == 0x0000) && (propositions[_propositionNumber].contractToRemoveId == 2**256 - 1)) )
        {
            // The promulgator choses to invalidate the promulgation
            propositions[_propositionNumber].wasEnded = true;
        }
        else
        {
            // We initiate the Organ interface to add a norm

        Organ affectedOrgan = Organ(affectedOrganContract);

            if(propositions[_propositionNumber].contractToAdd != 0x0000)
            {
                if (propositions[_propositionNumber].contractToRemoveId != 2**256 - 1)
                    { 
                        // Replacing a norm
                        affectedOrgan.replaceNorm(propositions[_propositionNumber].contractToRemoveId , propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size);
                    }
                else
                {
                    // Adding a new norm
                    affectedOrgan.addNorm(propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size );
                }
            }
            else 
            {
                // Removing a contract
                affectedOrgan.remNorm(propositions[_propositionNumber].contractToRemoveId);
            }        
            
        }
        propositions[_propositionNumber].wasEnded = true;
        propositionsWaitingPromulgation[_propositionNumber] = false;
        propositionToPromulgator[msg.sender].push(_propositionNumber);


        // promulgation event
        promulgatePropositionEvent(msg.sender, _propositionNumber, _promulgate);

    }

        //////////////////////// Functions to communicate with other contracts
    function getPropositionDetails(uint _propositionNumber) public view returns (address _addressToAdd, uint _addressToRemoveId, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size){
        return (propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].contractToRemoveId, propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size);
    }
    function getPropositionDates(uint _propositionNumber) public view returns (uint _startDate, uint _votingPeriodEndDate, uint _promulgatorWindowEndDate){
        return (propositions[_propositionNumber].startDate, propositions[_propositionNumber].votingPeriodEndDate, propositions[_propositionNumber].votingPeriodEndDate + promulgationPeriodDuration);
    }
    function getPropositionStatus(uint _propositionNumber) public view returns (bool _wasCounted, bool _wasEnded){
        return (propositions[_propositionNumber].wasCounted, propositions[_propositionNumber].wasEnded);
    }
    function getVotedPropositionResults(uint _propositionNumber) public view returns (bool _wasVetoed, bool _wasAccepted){
        require(propositions[_propositionNumber].wasCounted);
        return (propositions[_propositionNumber].wasVetoed, propositions[_propositionNumber].wasAccepted);
    }
    function getVotedPropositionStats(uint _propositionNumber) public view returns (uint _totalVoters, uint _totalVoteCount, uint _voteFor)
        {require(propositions[_propositionNumber].wasCounted);
        return (propositions[_propositionNumber].totalVoteCount, propositions[_propositionNumber].totalVoteCount, propositions[_propositionNumber].voteFor);}

    function getPropositionsCreatedByUser(address _userAddress) public view returns (uint[])
    {return propositionToUser[_userAddress];}    
    function getPropositionsVetoedByUser(address _userAddress) public view returns (uint[])
    {return propositionToVetoer[_userAddress];}  
    function getPropositionsPromulgatedByUser(address _userAddress) public view returns (uint[])
    {return propositionToPromulgator[_userAddress];}  
    function getPropositionsUsedByUser(address _userAddress) public view returns (uint[])
    {return propositionToVoter[_userAddress];}  
    function haveIVoted(uint propositionNumber) public view returns (bool IHaveVoted)
    {return propositions[propositionNumber].hasUserVoted[msg.sender];}
    // function getLinkedOrgans() public view returns (address[] _linkedOrgans)
    // {return linkedOrgans;}
    // function getProcedureName() public view returns (string _procedureName)
    // {return procedureName;}

}

