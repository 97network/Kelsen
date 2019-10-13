pragma solidity ^0.4.11;

// Standard contract for promulgation of a norm

import "../standardProcedure.sol";
import "../standardOrgan.sol";


contract voteOnAdminsAndMastersProcedure is Procedure{
    // 1: Cyclical many to one election (Presidential Election)
    // 2: Cyclical many to many election (Moderators Election)
    // 3: Simple norm nomination 
    // 4: Simple admins and master nomination
    // 5: Vote on Norms 
    // 6: Vote on masters and admins 
    // 7: Cooptation
    int public procedureTypeNumber = 6;

    // ############## Variable to set up when declaring the procedure
    // Organ in which the voters are registered
    address public votersOrganContract;

    // Organ in which people who can propose new propositions are registered
    address public propositionCreatorsOrganContract;

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

    // ######################

    // Variable of the procedure to keep track of propositions
    uint public totalPropositionNumber;

    // Proposition structure
    struct Proposition {

        // Proposition details
        address targetOrgan;
        address contractToAdd;
        address contractToRemove;
        bytes32 ipfsHash; // ID of proposal on IPFS
        uint8 hash_function;
        uint8 size;
        string name; // Admin name
        bool canAdd;  // if true, Admin can add norms
        bool canDelete;  // if true, Admin can delete norms
        bool canSpend;
        bool canDeposit;
        uint propositionType;


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

    event createPropositionEvent(address _from, address _targetOrgan, uint _propositionType, uint _propositionNumber);
    event createPropositionDetails(address _contractToAdd, address _contractToRemove);
    event createMasterPropositionEvent(uint _propositionNumber, bool _canAdd, bool _canDelete, string _name);
    event createAdminPropositionEvent(uint _propositionNumber, bool _canAdd, bool _canDelete, bool _canDeposit, bool _canSpend, string _name);
    event createNormPropositionEvent(uint _propositionNumber, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size, string name, uint _normNumber);

    event voteOnProposition(address _from, uint _propositionNumber);
    event vetoProposition(address _from, uint _propositionNumber);
    event countVotes(address _from, uint _propositionNumber);
    event promulgatePropositionEvent(address _from, uint _propositionNumber, bool _promulgate);

    /// Create a new ballot to choose one of `proposalNames`.
    function createProposition(address _targetOrgan, address _contractToAdd, address _contractToRemove, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size, string _name, bool _canAdd, bool _canDelete, bool _canDeposit, bool _canSpend, uint _propositionType) public returns (uint propositionNumber){

            // Check the proposition creator is able to make a proposition
            Organ propositionCreatorsOrgan = Organ(propositionCreatorsOrganContract);
            require(propositionCreatorsOrgan.isNorm(msg.sender));
            delete propositionCreatorsOrgan;

            // Retrieving proposition details
            Proposition memory newProposition;
            newProposition.targetOrgan = _targetOrgan;
            newProposition.contractToAdd = _contractToAdd;
            newProposition.contractToRemove = _contractToRemove;
            newProposition.ipfsHash = _ipfsHash;
            newProposition.hash_function = _hash_function;
            newProposition.size = _size;
            newProposition.canAdd = _canAdd;
            newProposition.canDelete = _canDelete;
            newProposition.canSpend = _canSpend;
            newProposition.canDeposit = _canDeposit;
            newProposition.propositionType = _propositionType;
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
            createPropositionEvent(msg.sender, propositions[propositionNumber].targetOrgan, _propositionType, propositionNumber);
            createPropositionDetails(_contractToAdd, _contractToRemove);
            
            // TODO
            if (!_canAdd && !_canDelete && !_canDeposit && !_canSpend)
            {
                // Norm proposition event
            createNormPropositionEvent(propositionNumber, _ipfsHash, _hash_function, _size, _name, _propositionType);
            }
            else if (_propositionType == 0)
            {
                // Master proposition event
            createMasterPropositionEvent(propositionNumber, _canAdd, _canDelete, _name);
            }
            else if (_propositionType == 1)
            {
                // Admin proposition event
            createAdminPropositionEvent(propositionNumber, _canAdd, _canDelete, _canDeposit, _canSpend, _name);
            }

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

    function promulgateProposition(uint _propositionNumber, bool _promulgate) public {
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

        if ((!_promulgate)||((propositions[_propositionNumber].contractToAdd == 0x0000) && (propositions[_propositionNumber].contractToRemove == 0x0000) && (propositions[_propositionNumber].ipfsHash == 0) && (propositions[_propositionNumber].propositionType == 0)) )
        {
            // The promulgator choses to invalidate the promulgation
            propositions[_propositionNumber].wasEnded = true;
            propositions[_propositionNumber].wasAccepted = false;
        }
        else
        {
            // We initiate the Organ interface to add an Admin

            Organ affectedOrgan = Organ(propositions[_propositionNumber].targetOrgan);
            // First, we check if there is a CONTRACT ADDRESS to add
            if (propositions[_propositionNumber].contractToAdd != 0x0000)
            {
                // There is a contract to add. We check if there is a CONTRACT ADDRESS to remove
                if (propositions[_propositionNumber].contractToRemove != 0x0000)
                    { 
                        // Replacing
                        if (propositions[_propositionNumber].propositionType == 0)
                        {
                        affectedOrgan.replaceMaster(propositions[_propositionNumber].contractToRemove, propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].canAdd, propositions[_propositionNumber].canDelete, propositions[_propositionNumber].name);
                        }
                        else if (propositions[_propositionNumber].propositionType == 1)
                        {
                        // Replacing an Admin
                        affectedOrgan.replaceAdmin(propositions[_propositionNumber].contractToRemove, propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].canAdd, propositions[_propositionNumber].canDelete, propositions[_propositionNumber].canDeposit, propositions[_propositionNumber].canSpend, propositions[_propositionNumber].name);
                        }
                        else
                        {
                        affectedOrgan.replaceNorm(affectedOrgan.getAddressPositionInNorm(propositions[_propositionNumber].contractToRemove) , propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size);
                        }

                    }
                // We check if there is an ENTRY NUMBER to remove. If there is an entry to remove, it is propositionType - 2. Entry 0 can not be removed.    
                else if (propositions[_propositionNumber].propositionType > 2 )
                {
                    // This means we replace a hash reference with a contract address. Cool.
                    affectedOrgan.replaceNorm((propositions[_propositionNumber].propositionType-2), propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size);

                }
                // Ok so there is NO contract to remove, and no hash reference to replace. We're just adding a new entry.
                else
                {
                    // Adding
                        if (propositions[_propositionNumber].propositionType == 0)
                        {
                        affectedOrgan.addMaster(propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].canAdd, propositions[_propositionNumber].canDelete, propositions[_propositionNumber].name);
                        }
                        else if (propositions[_propositionNumber].propositionType == 1)
                        {
                        // Adding an Admin
                        affectedOrgan.addAdmin(propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].canAdd, propositions[_propositionNumber].canDelete, propositions[_propositionNumber].canDeposit, propositions[_propositionNumber].canSpend, propositions[_propositionNumber].name);
                        }
                        else if (propositions[_propositionNumber].propositionType == 2)
                        {//Adding a has reference
                        affectedOrgan.addNorm(propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size );
                        }

                }
            }
            // Then, we check if there is a CONTRACT ADDRESS to remove
            else if (propositions[_propositionNumber].contractToRemove != 0x0000)
            {
                // Ok so there is ONLY a contract address to remove. Good to know. There might be a hash reference too, so we'll check it out.
                // Is it a master?
                if (propositions[_propositionNumber].propositionType == 0)
                {
                affectedOrgan.remMaster(propositions[_propositionNumber].contractToRemove);
                }
                // Is it an admin?
                else if (propositions[_propositionNumber].propositionType == 1)
                {
                // Removing an Admin
                affectedOrgan.remAdmin(propositions[_propositionNumber].contractToRemove);
                }
                // Ok, so it's a norm
                else
                {
                // Removing/replacing a norm
                if (propositions[_propositionNumber].ipfsHash != 0)
                    {
                    affectedOrgan.replaceNorm(propositions[_propositionNumber].propositionType , propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size);
                    }
                else 
                    {
                    affectedOrgan.remNorm(affectedOrgan.getAddressPositionInNorm(propositions[_propositionNumber].contractToRemove));
                    }
                
                }
            }
            // Ok, so finally this means there is NO contract address to add and NO contract address to remove. We are dealing with a hash reference. So implicitly, with a norm.
            else if (propositions[_propositionNumber].ipfsHash != 0) 
            {
                // this is the situation where there is no contract to add, no contract to remove, BUT there is a hash reference.
                // This means it is either an addition, or a replacement.
                // Addition will have propositionType set to 0. Replacement will store the norm number to replace in propositionType.
                if (propositions[_propositionNumber].propositionType != 0)
                {
                    // Replacing
                    affectedOrgan.replaceNorm(propositions[_propositionNumber].propositionType , propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size);
            
                }
                else
                {
                    //Adding a hash reference
                affectedOrgan.addNorm(propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size );

                }

            }
            // Ok so if there no contract address to add / remove, no IPFS content... Then it means we are removing a norm. The norm number shall be stored in propositionType.
            else 
            {
                // Removing a norm
                affectedOrgan.remNorm(propositions[_propositionNumber].propositionType);   
            }        
            
        }
        propositions[_propositionNumber].wasEnded = true;
        propositionsWaitingPromulgation[_propositionNumber] = false;
        propositionToPromulgator[msg.sender].push(_propositionNumber);


        // promulgation event
        promulgatePropositionEvent(msg.sender, _propositionNumber, _promulgate);

    }

    // function archiveDefunctProposition(uint _propositionNumber) public {
    //     // If a proposition contains an instruction that can not be executed (eg "add an admin" without having canAdd enabled), this proposition can be closed

    //     Organ targetOrganContract = Organ(propositions[_propositionNumber].targetOrgan);
    //     bool canAdd;
    //     bool canDelete;
    //     if (propositions[_propositionNumber].propositionType < 2){
    //         (canAdd, canDelete) = targetOrganContract.isMaster(address(this));
    //     }
    //     else {
    //         (canAdd, canDelete) = targetOrganContract.isAdmin(address(this));
    //     }
        
    //     if ((!canAdd && (propositions[_propositionNumber].contractToAdd != 0x0000)) || (!canDelete && (propositions[_propositionNumber].contractToRemove != 0x0000)) )
    //     {
    //         propositions[_propositionNumber].wasEnded = true;
    //         propositionsWaitingPromulgation[_propositionNumber] = false;
    //     }
    //     promulgatePropositionEvent(msg.sender, _propositionNumber, false);

    // }


    //////////////////////// Functions to communicate with other contracts

    function getPropositionDetails(uint _propositionNumber) public view returns (address _addressToAdd, address _addressToRemove, bool _canAdd, bool _canDelete, bool _canDeposit, bool _canSpend, string _name){
        return (propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].contractToRemove, propositions[_propositionNumber].canAdd, propositions[_propositionNumber].canDelete, propositions[_propositionNumber].canDeposit, propositions[_propositionNumber].canSpend, propositions[_propositionNumber].name);
    }
    function getPropositionDocumentation(uint _propositionNumber) public view returns (address _addressToAdd, address _addressToRemove, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size, uint _propositionType, address _targetOrgan){
        return (propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].contractToRemove, propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size, propositions[_propositionNumber].propositionType, propositions[_propositionNumber].targetOrgan);
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
    // function updateLinkedOrgans(address _linkedOrgan) public {
    //     bool isLinked = checkLinkedOrgan(_linkedOrgan);
    //     bool isRegistered = false;
    //     for (uint p = 0; p < linkedOrgans.length; p++) {
    //         if (linkedOrgans[p] == _linkedOrgan)
    //         {
    //             if (!isLinked)
    //             {
    //                 delete(linkedOrgans[p]);       
    //             }
    //             isRegistered = true;
    //         }

    //     }
    //     if (isLinked && !isRegistered)
    //     {
    //     linkedOrgans.push(_linkedOrgan);
    //     }
    // }
    // function checkLinkedOrgan(address _linkedOrgan) public view returns (bool){
    //     Organ supposedlyLinkedOrgan = Organ(_linkedOrgan);
    //     bool adminCanAdd;
    //     bool adminCanDelete;
    //     bool masterCanAdd;
    //     bool masterCanDelete;
    //     bool canDeposit;
    //     bool canSpend;
    //     (adminCanAdd, adminCanDelete) = supposedlyLinkedOrgan.isAdmin(address(this));
    //     (masterCanAdd, masterCanDelete) = supposedlyLinkedOrgan.isMaster(address(this));
    //     (canDeposit, canSpend) = supposedlyLinkedOrgan.isMoneyManager(address(this));
    //     if( adminCanAdd || adminCanDelete || masterCanAdd || masterCanDelete || canDeposit || canSpend)
    //         {return true;}
    //     else
    //         {return false;}
    // }
    // function getLinkedOrgans() public view returns (address[] _linkedOrgans)
    // {return linkedOrgans;}
    // function getProcedureName() public view returns (string _procedureName)
    // {return procedureName;}


}

