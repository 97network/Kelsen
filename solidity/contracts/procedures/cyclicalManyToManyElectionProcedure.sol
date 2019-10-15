pragma solidity ^0.4.11;

// Standard contract for a presidential election procedure

import "../standardProcedure.sol";
import "../standardOrgan.sol";


contract cyclicalManyToManyElectionProcedure is Procedure{
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

    int public procedureTypeNumber = 2;

    // string public procedureName;
    // // Gathering connected organs for easier DAO mapping
    // address[] public linkedOrgans;

    // Which organ will be affected
    address public affectedOrganContract;

    // Where are the voter registered
    address public referenceOrganContract;

    

    // ############## Variable to set up when declaring the procedure
    // ####### Vote creation process
    // Election frequency
    uint public ballotFrequency;
    // Max parallel election running
    uint public nextElectionDate;

    // current President address
    address[] public currentModerators;

    // ####### Voting process
    // Time to vote
    uint public ballotDuration;

    // Is blank vote accepted
    bool public neutralVoteAccepted;

    // ####### Candidacy process
    // Time to declare as a candidate
    uint public candidacyDuration;
    // Maximum time someone can be candidate
    uint public reelectionMaximum;

    // ####### Resolution process
    // Minimum participation to validate election
    uint public quorumSize;

    // Number of candidate per voter
    uint public voterToCandidateRatio;


    // Variable of the procedure to keep track of events
    bool public isBallotCurrentlyRunning;
    uint public totalBallotNumber;
    uint public lastElectionNumber;

    // Structure declaration

    // Voter structure, to keep track of who voted for the current election
    struct Voter {
        bool voted;  // if true, that person already voted
        bool isCandidate;
        mapping(address => bool) hasVotedForCandidate;
    }



    // Candidacies structure, to keep track of candidacies for an election
    struct Candidacy {
        string name;
        bytes32 ipfsHash; // ID of proposal on IPFS
        uint8 hash_function;
        uint8 size;
        uint voteNumber;
    }

    // Ballot structure, instanciated once for every election cycle
    struct Ballot {
        address creator;
        string name;   // short name (up to 32 bytes)
        mapping(address => Voter) voters;
        mapping(address => Candidacy) candidacies;
        address[] candidateList;
        uint electedOfficialSlotNumber;
        uint startDate;
        uint candidacyEndDate;
        uint electionEndDate;
        bool wasEnded;
        bool wasEnforced;
        address[] winningCandidates;
        uint totalVoteCount;
        uint totalVoters;

    }

    // A dynamically-sized array of `Ballot` structs.
    Ballot[] public ballots;

    // A mapping of candidacy status and number of candidacies per member
    mapping(address => uint) public cumulatedCandidacies;

    // Mapping each proposition to the user creating it
    mapping (address => uint[]) public ballotToCreator;    

    // Mapping each proposition to the user creating it
    mapping (address => uint[]) public ballotToVoter;

    // Mapping each proposition to the user counting it
    mapping (address => uint[]) public ballotToCounter;

    // Mapping each proposition to the user enforcing it
    mapping (address => uint[]) public ballotToEnforcer;

    // Events
    event ballotCreationEvent(address _from, string _name, uint _startDate, uint _candidacyEndDate, uint _endDate, uint _ballotNumber);
    event presentCandidacyEvent(uint _ballotNumber, address _candidateAddress, string _name, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size);
    event votedOnElectionEvent(address _from, uint _ballotNumber);
    event ballotWasCounted(uint _ballotNumber, address[] _candidateList, address[] _winningCandidates, uint _totalVoteCount);
    event ballotResultException(uint _ballotNumber, bool _wasRebooted);
    event ballotWasEnforced(address[] _winningCandidates, uint _ballotNumber);

    /// Create a new ballot to choose one of `proposalNames`.
    function createBallot(string _ballotName) public returns (uint ballotNumber){
            // Checking no ballot is currently running
            require (isBallotCurrentlyRunning == false);
            // Checking that election date has passed
            require (now > nextElectionDate);
            // Checking if previous ballot was counted
            if (ballots.length > 0) {
                require(ballots[lastElectionNumber].wasEnded);
            }

            Ballot memory newBallot;
            newBallot.creator = msg.sender;
            newBallot.name = _ballotName;
            newBallot.startDate = now;
            newBallot.candidacyEndDate = now + candidacyDuration;
            newBallot.electionEndDate = now + candidacyDuration+ballotDuration;
            newBallot.wasEnded = false;
            newBallot.totalVoteCount =0;
            newBallot.totalVoters =0;

            // Retrieving size of electorate
            Organ voterRegistryOrgan = Organ(referenceOrganContract);
            newBallot.electedOfficialSlotNumber = uint(voterRegistryOrgan.getActiveNormNumber())/uint(voterToCandidateRatio);
            if ( newBallot.electedOfficialSlotNumber == 0) { newBallot.electedOfficialSlotNumber = 1;}
            delete voterRegistryOrgan;


            ballots.push(newBallot);
            ballotNumber = ballots.length - 1;
            // openBallotList.push(ballotNumber);
            // currentBallot = ballotNumber;
            totalBallotNumber += 1;
            isBallotCurrentlyRunning = true;
            nextElectionDate = now + ballotFrequency;
            lastElectionNumber = ballotNumber;

            // Log event
            ballotCreationEvent(msg.sender, _ballotName, newBallot.startDate, newBallot.candidacyEndDate, newBallot.electionEndDate, ballotNumber);
           
            // Attribute creation to creator
            ballotToCreator[msg.sender].push(ballotNumber);

            return ballotNumber;
            }

    function presentCandidacy(uint _ballotNumber, string _name, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size) public {

        // Check the candidate is a member of the reference organ
        Organ voterRegistryOrgan = Organ(referenceOrganContract);
        require(voterRegistryOrgan.isNorm(msg.sender));
        delete voterRegistryOrgan;

        // Check that the ballot is still active
        require(!ballots[_ballotNumber].wasEnded);

        // Check that the ballot candidacy period is still open
        require(ballots[_ballotNumber].candidacyEndDate > now);

        // Check that sender is not over the mandate limit
        require(cumulatedCandidacies[msg.sender] < reelectionMaximum);

        // Check if the candidate is already candidate
        require(!ballots[_ballotNumber].voters[msg.sender].isCandidate);

        ballots[_ballotNumber].candidateList.push(msg.sender);
        ballots[_ballotNumber].voters[msg.sender].isCandidate = true;

        ballots[_ballotNumber].candidacies[msg.sender].name = _name;
        ballots[_ballotNumber].candidacies[msg.sender].ipfsHash = _ipfsHash;
        ballots[_ballotNumber].candidacies[msg.sender].hash_function = _hash_function;
        ballots[_ballotNumber].candidacies[msg.sender].size = _size;
        ballots[_ballotNumber].candidacies[msg.sender].voteNumber = 0;
       
        // Log event
        presentCandidacyEvent(_ballotNumber, msg.sender, _name, _ipfsHash, _hash_function, _size);

        }


    /// Vote for a candidate
    function vote(uint _ballotNumber, address[] _candidateAddresses) public {

        Organ voterRegistryOrgan = Organ(referenceOrganContract);
        require(voterRegistryOrgan.isNorm(msg.sender));

        delete voterRegistryOrgan;

        // Check if voter already voted
        require(!ballots[_ballotNumber].voters[msg.sender].voted);

        // Check if vote is still active
        require(!ballots[_ballotNumber].wasEnded);

        // Check if candidacy period is over
        require(ballots[_ballotNumber].candidacyEndDate < now);

        // Check if voting period ended
        require(ballots[_ballotNumber].electionEndDate > now);

        // Checking that the voter has not selected too much candidates
        require(_candidateAddresses.length < ballots[_ballotNumber].electedOfficialSlotNumber + 1);
        
        // Checking that the voter selected at least one candidate
        require(_candidateAddresses.length > 0);

        // Going through the list of selected candidates
        for (uint i = 0; i < _candidateAddresses.length; i++)
        {
            require(!ballots[_ballotNumber].voters[msg.sender].hasVotedForCandidate[_candidateAddresses[i]]);
            if(ballots[_ballotNumber].voters[_candidateAddresses[i]].isCandidate)
                {ballots[_ballotNumber].candidacies[_candidateAddresses[i]].voteNumber += ballots[_ballotNumber].electedOfficialSlotNumber-i;
                    ballots[_ballotNumber].totalVoteCount += ballots[_ballotNumber].electedOfficialSlotNumber-i;
                    ballots[_ballotNumber].voters[msg.sender].hasVotedForCandidate[_candidateAddresses[i]] = true;}
            else
                // If candidate does not exist, this is a neutral vote
            {ballots[_ballotNumber].candidacies[0x0000].voteNumber += 1;}

        }


        ballots[_ballotNumber].voters[msg.sender].voted = true;

        ballots[_ballotNumber].totalVoters += 1;

        // Attribute vote to voter
        ballotToVoter[msg.sender].push(_ballotNumber);

        // Log event
        votedOnElectionEvent(msg.sender, _ballotNumber);


        }

    // The vote is finished and we close it. This triggers the outcome of the vote.

    function endBallot(uint _ballotNumber) public {
        // We check if the vote was already closed
        require(!ballots[_ballotNumber].wasEnded);

        // Checking that the vote can be closed
        require(ballots[_ballotNumber].electionEndDate < now);

        // Checking that the vote can be closed
        if ((ballots[_ballotNumber].candidateList.length == 0) || ballots[_ballotNumber].totalVoteCount == 0)
        {
                // ballotHasEnded(false, true, ballots[_ballotNumber].candidateList, ballots[_ballotNumber].winningCandidates, ballots[_ballotNumber].totalVoteCount );
                nextElectionDate = now -1;
                isBallotCurrentlyRunning = false;
                ballots[_ballotNumber].wasEnded = true;
                ballots[_ballotNumber].wasEnforced = true;
                // Log event
                ballotResultException(_ballotNumber, true);
                // Rebooting election
                createBallot(ballots[_ballotNumber].name);
                return;
        }

        // Checking that there are enough candidates
        if (ballots[_ballotNumber].candidateList.length < ballots[_ballotNumber].electedOfficialSlotNumber)
        {
            ballots[_ballotNumber].electedOfficialSlotNumber = ballots[_ballotNumber].candidateList.length;
        } 


        // ############## Going through candidates to check the vote count
        uint previousThresholdCount = uint(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        uint winningVoteCount = 0;
        uint isADraw = 0;
        uint roundWinningCandidate = 0;

        Organ voterRegistryOrgan = Organ(referenceOrganContract);

        // Check if quorum is obtained. We avoiding divisions here, since Solidity is not good to calculate divisions
        if (ballots[_ballotNumber].totalVoters*100 < quorumSize*voterRegistryOrgan.getActiveNormNumber())
        {
            // Quorum was not obtained. Rebooting election
            ballots[_ballotNumber].wasEnforced = true;
            nextElectionDate = now -1;
            isBallotCurrentlyRunning = false;
            ballots[_ballotNumber].wasEnded = true;

            // Log event
            ballotResultException(_ballotNumber, true);
            // Rebooting election
            createBallot(ballots[_ballotNumber].name);
            return;
        }
        delete voterRegistryOrgan;


        // Going through candidate lists to check all elected moderators
        for (uint i = 0; i < ballots[_ballotNumber].electedOfficialSlotNumber; i++)
        {
            winningVoteCount = 0;
            roundWinningCandidate = 0;
                // Going through candidate list once to find best suitor
                for (uint p = 0; p < ballots[_ballotNumber].candidateList.length; p++)
                {
                    address _candidateAddress = ballots[_ballotNumber].candidateList[p];
                    if (ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber >= previousThresholdCount)
                    {}
                    else if (ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber > winningVoteCount) {
                        winningVoteCount = ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber ;
                        roundWinningCandidate = p;
                        isADraw = 0;
                        }
                    else if (ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber == winningVoteCount){
                            isADraw += 1;
                        }

                }

                // Checking if various candidates tied
                if (winningVoteCount == 0)
                {}
                else if (isADraw > 0)
                {
                    // Going through list one more time to add all tied up candidates
                    for (uint q = 0; q < ballots[_ballotNumber].candidateList.length; q++)
                    {
                        // Making sure that winning candidate number is not too big
                        if (i >= ballots[_ballotNumber].electedOfficialSlotNumber){}
                        // Detecting ties
                        else if (ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber == winningVoteCount)
                            {
                                ballots[_ballotNumber].winningCandidates.push(ballots[_ballotNumber].candidateList[q]);
                                i += 1;
                            }
                    }
                }
                // Adding candidate to winning candidate list
                else {
                    ballots[_ballotNumber].winningCandidates.push(ballots[_ballotNumber].candidateList[roundWinningCandidate]);
                }

                previousThresholdCount = winningVoteCount;
            }

        // ############## Updating ballot values if vote concluded
        ballots[_ballotNumber].wasEnded = true;
        isBallotCurrentlyRunning = false;
        // Log event
        ballotWasCounted(_ballotNumber, ballots[_ballotNumber].candidateList, ballots[_ballotNumber].winningCandidates, ballots[_ballotNumber].totalVoteCount );
        // Attribute count to counter
        ballotToCounter[msg.sender].push(_ballotNumber);

        }
    
    function enforceBallot(uint _ballotNumber) public {
        // Checking if ballot was already enforced
        require(!ballots[_ballotNumber].wasEnforced );
        // Checking the ballot was closed
        require(ballots[_ballotNumber].wasEnded);
        // Checking that the enforcing date is not later than the end of his supposed mandate
        if (now > ballots[_ballotNumber].startDate + ballotFrequency)
        {
            ballots[_ballotNumber].wasEnforced = true;
            // Log event
            ballotResultException(_ballotNumber, false);
            return;
        }
        // We initiate the Organ interface to add a presidential norm

        Organ moderatorsOrgan = Organ(affectedOrganContract);


        // Removing current moderators
        if (totalBallotNumber > 1)
            {
            for (uint i = 0; i < currentModerators.length; i++)
                {
                    moderatorsOrgan.remNorm(moderatorsOrgan.getAddressPositionInNorm(currentModerators[i]));
                    delete currentModerators[i];
                }
            }

        // Adding new moderators
        for (uint p = 0; p < ballots[_ballotNumber].winningCandidates.length; p++)
            {
                Candidacy memory newModerator = ballots[_ballotNumber].candidacies[ballots[_ballotNumber].winningCandidates[p]];
                moderatorsOrgan.addNorm(ballots[_ballotNumber].winningCandidates[p], newModerator.name, newModerator.ipfsHash, newModerator.hash_function, newModerator.size  );
                cumulatedCandidacies[ballots[_ballotNumber].winningCandidates[p]] += 1;
                if (p < currentModerators.length )
                {
                 currentModerators[p] = ballots[_ballotNumber].winningCandidates[p];
                }
                else
                {
                    currentModerators.push(ballots[_ballotNumber].winningCandidates[p]);
                }
            }

        // Modifying procedure variable to count new president
        ballots[_ballotNumber].wasEnforced = true;


        ballotToEnforcer[msg.sender].push(_ballotNumber);
        
        // Logging event
        ballotWasEnforced( ballots[_ballotNumber].winningCandidates, _ballotNumber);
        }

    //////////////////////// Functions to communicate with other contracts
    function getCandidateList(uint _ballotNumber) public view returns (address[] _candidateList){
        return ballots[_ballotNumber].candidateList;
    }
    function getSingleBallotInfo(uint _ballotNumber) public view returns (string _name, uint _startDate, uint _candidacyEndDate, uint _electionEndDate, uint _electedOfficialSlotNumber){
        return (ballots[_ballotNumber].name, ballots[_ballotNumber].startDate, ballots[_ballotNumber].candidacyEndDate, ballots[_ballotNumber].electionEndDate, ballots[_ballotNumber].electedOfficialSlotNumber);
    }
    function getBallotStatus(uint _ballotNumber) public view returns (bool _wasEnded, bool _wasEnforced, address[] _winningCandidates)
    { return (ballots[_ballotNumber].wasEnded, ballots[_ballotNumber].wasEnforced, ballots[_ballotNumber].winningCandidates);}

    function getBallotStats(uint _ballotNumber) public view returns (uint _votersNumber, uint _totalVoteCount)
    { return (ballots[_ballotNumber].totalVoters, ballots[_ballotNumber].totalVoteCount);}
    
    function getCandidateVoteNumber(uint _ballotNumber, address _candidateAddress) public view returns (uint voteReceived){
        require(ballots[_ballotNumber].wasEnded);
        return ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber;
    }
    function haveIVoted(uint _ballotNumber) public view returns (bool IHaveVoted)
    {return ballots[_ballotNumber].voters[msg.sender].voted;}

    function getBallotToCreator(address _userAddress) public view returns (uint[])
    {return ballotToCreator[_userAddress];}    
    function getBallotToVoter(address _userAddress) public view returns (uint[])
    {return ballotToVoter[_userAddress];}  
    function getBallotToCounter(address _userAddress) public view returns (uint[])
    {return ballotToCounter[_userAddress];}  
    function getBallotToEnforcer(address _userAddress) public view returns (uint[])
    {return ballotToEnforcer[_userAddress];}  
    // function getLinkedOrgans() public view returns (address[] _linkedOrgans)
    // {return linkedOrgans;}
    // function getProcedureName() public view returns (string _procedureName)
    // {return procedureName;}


}
