pragma solidity ^0.4.11;

// Standard contract for a presidential election procedure

import "../standardProcedure.sol";
import "../standardOrgan.sol";


contract cyclicalManyToOneElectionProcedure is Procedure{

    // 1: Cyclical many to one election (Presidential Election)
    // 2: Cyclical many to many election (Moderators Election)
    // 3: Simple norm nomination 
    // 4: Simple admins and master nomination
    // 5: Vote on Norms 
    // 6: Vote on masters and admins 
    // 7: Cooptation

    int public procedureTypeNumber = 1;

    // // Storage for procedure name
    // string public procedureName;
    
    // // Gathering connected organs for easier DAO mapping
    // address[] public linkedOrgans;

    // Which contract will be affected
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
    address public currentPresident;

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


    // Variable of the procedure to keep track of events
    bool public isBallotCurrentlyRunning;
    uint public totalBallotNumber;
    uint public lastElectionNumber;

    // List of open ballots
    // uint[] public openBallotList;
    // uint public currentBallot;

    // Structure declaration

    // Voter structure, to keep track of who voted for the current election
    struct Voter {
        bool voted;  // if true, that person already voted
        bool isCandidate;
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
        uint startDate;
        uint candidacyEndDate;
        uint electionEndDate;
        bool wasEnded;
        bool wasEnforced;
        address winningCandidate;
        uint totalVoteCount;

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
    event ballotWasCounted(uint _ballotNumber, address[] _candidateList, address _winningCandidate, uint _totalVoteCount);
    event ballotResultException(uint _ballotNumber, bool _wasRebooted);
    event ballotWasEnforced(address _winningCandidate, uint _ballotNumber);


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
            newBallot.winningCandidate = 0x0000;
            newBallot.totalVoteCount =0;
            ballots.push(newBallot);

            ballotNumber = ballots.length - 1;
            // openBallotList.push(ballotNumber);
            // currentBallot = ballotNumber;
            totalBallotNumber += 1;
            isBallotCurrentlyRunning = true;
            nextElectionDate = now + ballotFrequency;
            lastElectionNumber = ballotNumber;

            // Ballot creation event
            ballotCreationEvent(msg.sender, newBallot.name, newBallot.startDate, newBallot.candidacyEndDate, newBallot.electionEndDate, ballotNumber);
            
            // Loggin that ballot creator did create this ballot
            ballotToCreator[msg.sender].push(ballotNumber);

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
         // Candidacy event is turned off for now
        presentCandidacyEvent(_ballotNumber, msg.sender, _name, _ipfsHash, _hash_function, _size);



        }


    /// Vote for a candidate
    function vote(uint _ballotNumber, address _candidateAddress) public {

        Organ voterRegistryOrgan = Organ(referenceOrganContract);
        require(voterRegistryOrgan.isNorm(msg.sender));

        delete voterRegistryOrgan;
        
        // Check if voter already votred
        require(!ballots[_ballotNumber].voters[msg.sender].voted);

        // Check if vote is still active
        require(!ballots[_ballotNumber].wasEnded);

        // Check if candidacy period is over
        require(ballots[_ballotNumber].candidacyEndDate < now);

        // Check if voting period ended
        require(ballots[_ballotNumber].electionEndDate > now);

        // Check if candidate for whom we voted for is declared
        if(ballots[_ballotNumber].voters[_candidateAddress].isCandidate)
        {ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber += 1;}
        else
            // If candidate does not exist, this is a neutral vote
        {ballots[_ballotNumber].candidacies[0x0000].voteNumber += 1;}

        ballots[_ballotNumber].voters[msg.sender].voted = true;
        
        ballots[_ballotNumber].totalVoteCount += 1;

        // Associating vote with voter for gamification purposes
        ballotToVoter[msg.sender].push(_ballotNumber);

        // Event
        votedOnElectionEvent(msg.sender, _ballotNumber);
                        

            }

    // The vote is finished and we close it. This triggers the outcome of the vote.

    function endBallot(uint _ballotNumber) public returns (uint winningCandidate){
            // We check if the vote was already closed
            require(!ballots[_ballotNumber].wasEnded);

            // Checking that the vote can be closed
            require(ballots[_ballotNumber].electionEndDate < now);

            // Checking that the vote can be closed
            if ((ballots[_ballotNumber].candidateList.length == 0) || ballots[_ballotNumber].totalVoteCount == 0)
            {
                    ballots[_ballotNumber].wasEnforced = true;
                    ballots[_ballotNumber].wasEnded = true;
                    ballotResultException(_ballotNumber, true);
                    nextElectionDate = now -1;
                    isBallotCurrentlyRunning = false;
                    createBallot(ballots[_ballotNumber].name);
                    return 0;
            }


            // ############## Going through candidates to check the vote count
            uint winningVoteCount = 0;
            bool isADraw = false;
            bool quorumIsObtained = false;

            Organ voterRegistryOrgan = Organ(referenceOrganContract);

            // Check if quorum is obtained. We avoiding divisions here, since Solidity is not good to calculate divisions
            if (ballots[_ballotNumber].totalVoteCount*100 >= quorumSize*voterRegistryOrgan.getActiveNormNumber())
            {quorumIsObtained = true;}

            // Going through candidates list
            for (uint p = 0; p < ballots[_ballotNumber].candidateList.length; p++) {
                address _candidateAddress = ballots[_ballotNumber].candidateList[p];
                if (ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber > winningVoteCount) {
                    winningVoteCount = ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber ;
                    winningCandidate = p;
                    isADraw = false;
                }
                else if (ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber == winningVoteCount){
                    isADraw = true;
                }

            }

            // ############## Updating ballot values if vote concluded
            ballots[_ballotNumber].wasEnded = true;
            isBallotCurrentlyRunning = false;

            if (!isADraw && quorumIsObtained)
                // The ballot completed succesfully
            {


            ballots[_ballotNumber].winningCandidate = ballots[_ballotNumber].candidateList[winningCandidate];
            ballotWasCounted(_ballotNumber, ballots[_ballotNumber].candidateList, ballots[_ballotNumber].winningCandidate, ballots[_ballotNumber].totalVoteCount);

                }
                else
                    // The ballot did not conclude correctly. We reboot the election process.
                {
                    ballots[_ballotNumber].wasEnforced = true;
                    ballotResultException(_ballotNumber, true);
                    nextElectionDate = now -1;
                    ballots[_ballotNumber].wasEnded = true;
                    isBallotCurrentlyRunning = false;
                    createBallot(ballots[_ballotNumber].name);
                }

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
            ballotResultException(_ballotNumber, false);                  
            return;
        }

        // We initiate the Organ interface to add a presidential norm

        Organ presidentialOrgan = Organ(affectedOrganContract);
        address newPresidentAddress = ballots[_ballotNumber].winningCandidate;

        // Adding new president first
            // function addNorm (string _name, address _normAdress, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size) public  returns (bool success);
        if (newPresidentAddress != currentPresident)
            {
            Candidacy memory newPresident = ballots[_ballotNumber].candidacies[newPresidentAddress];
            presidentialOrgan.addNorm(newPresidentAddress, newPresident.name, newPresident.ipfsHash, newPresident.hash_function, newPresident.size );

            

            // Removing former president, only if a former election was conducted.
            if (totalBallotNumber > 1){
            presidentialOrgan.remNorm(presidentialOrgan.getAddressPositionInNorm(currentPresident));
                }


            // Modifying procedure variable to count new president
            currentPresident = newPresidentAddress;

            }
        cumulatedCandidacies[newPresidentAddress] += 1;
        ballots[_ballotNumber].wasEnforced = true;
        // delete openBallotList[_ballotNumber];
        // currentBallot = 0;

        // Adjusting mandate duration
        // nextElectionDate = now + ballotFrequency - candidacyDuration - ballotDuration;
        ballotWasEnforced( newPresidentAddress, _ballotNumber);
        ballotToEnforcer[msg.sender].push(_ballotNumber);                

         }
        //////////////////////// Functions to communicate with other contracts
    

    // ######### Functions to retrieve procedure infos

    function getCandidateList(uint _ballotNumber) public view returns (address[] _candidateList){
        return ballots[_ballotNumber].candidateList;
    }
 // Ballot related infos
    function getSingleBallotInfo(uint _ballotNumber) public view returns (string _name, uint _startDate, uint _candidacyEndDate, uint _electionEndDate)
    {return (ballots[_ballotNumber].name, ballots[_ballotNumber].startDate, ballots[_ballotNumber].candidacyEndDate, ballots[_ballotNumber].electionEndDate);}
    function getBallotStatus(uint _ballotNumber) public view returns (bool _wasEnded, bool _wasEnforced, address _winningCandidate, uint _totalVoteCount)
    { return (ballots[_ballotNumber].wasEnded, ballots[_ballotNumber].wasEnforced, ballots[_ballotNumber].winningCandidate, ballots[_ballotNumber].totalVoteCount);}

    function getBallotDates(uint _ballotNumber) public view returns (uint startDate, uint endDate)
    {return (ballots[_ballotNumber].startDate, ballots[_ballotNumber].electionEndDate);}
    
    function getBallotStats(uint _ballotNumber) public view returns (uint _votersNumber, uint _totalVoteCount)
    { return (ballots[_ballotNumber].totalVoteCount, ballots[_ballotNumber].totalVoteCount);}

    function haveIVoted(uint _ballotNumber) public view returns (bool IHaveVoted)
    {return ballots[_ballotNumber].voters[msg.sender].voted;}
    function getCandidateVoteNumber(uint _ballotNumber, address _candidateAddress) public view returns (uint voteReceived){
        require(ballots[_ballotNumber].wasEnded);
        return ballots[_ballotNumber].candidacies[_candidateAddress].voteNumber;
    }
    function getBallotToCreator(address _userAddress) public view returns (uint[])
    {return ballotToCreator[_userAddress];}    
    function getBallotToCounter(address _userAddress) public view returns (uint[])
    {return ballotToCounter[_userAddress];}  
    function getBallotToEnforcer(address _userAddress) public view returns (uint[])
    {return ballotToEnforcer[_userAddress];}  
    // function getLinkedOrgans() public view returns (address[] _linkedOrgans)
    // {return linkedOrgans;}
    // function getProcedureName() public view returns (string _procedureName)
    // {return procedureName;}

}

