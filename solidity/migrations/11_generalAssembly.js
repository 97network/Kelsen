
var Migrations = artifacts.require("./Migrations.sol");
var organLibrary = artifacts.require('./libraries/organLibrary.sol')
var procedureLibrary = artifacts.require('./libraries/procedureLibrary.sol')
var propositionVotingLibrary = artifacts.require('./libraries/propositionVotingLibrary.sol')
var Organ = artifacts.require('./Organ.sol')
var simpleNormNominationProcedure = artifacts.require("./procedures/simpleNormNominationProcedure")
var voteOnAdminsAndMastersProcedure = artifacts.require("./procedures/voteOnAdminsAndMastersProcedure")
var generalAssemblyProcedure = artifacts.require("./procedures/generalAssemblyProcedure")


// const BihuInsurance = artifacts.require('./bihuInsurancePlan.sol')
// var PlanManagementLib = artifacts.require("./libraries/planManagementLib.sol");
// const SubscriptionManagementLib = artifacts.require("./libraries/subscriptionManagementLib.sol");
// const ClaimsAndRecoursesManagementLib = artifacts.require("./libraries/claimsAndRecoursesManagementLib.sol");
// const BihuToken = artifacts.require("./libraries/bihuToken.sol");
// const timeTrackingContract = artifacts.require('./utils/DateTime.sol')
// const SimpleNormNominationProcedure = artifacts.require('./utils/Kelsen/procedures/simpleNormNominationProcedure.sol')
// var voteOnAdminsAndMastersProcedure = artifacts.require("utils/Kelsen/solidity/contracts/procedures/voteOnAdminsAndMastersProcedure")
// var simpleNormNominationProcedure = artifacts.require("utils/Kelsen/solidity/contracts/procedures/simpleNormNominationProcedure")
// var voteOnNormsProcedure = artifacts.require("utils/Kelsen/solidity/contracts/procedures/voteOnNormsProcedure")
// var cyclicalManyToOneElectionProcedure = artifacts.require("utils/Kelsen/solidity/contracts/procedures/cyclicalManyToOneElectionProcedure")
// var cyclicalManyToManyElectionProcedure = artifacts.require("utils/Kelsen/solidity/contracts/procedures/cyclicalManyToManyElectionProcedure")
// var arbitrationProcess = artifacts.require('./arbitrationProcess.sol')

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await setContractVariables(deployer, network, accounts);
        await deployLibs(deployer, network, accounts);
        await declareOrgans(deployer, network, accounts);
        await declareProcedures(deployer, network, accounts);
        await setOrganAdminsAndMasters(deployer, network, accounts);
        await setOrganNorms(deployer, network, accounts);
        await cleanInstallation(deployer, network, accounts);
        await installationRecap(deployer, network, accounts);
    });
};
async function setContractVariables(deployer, network, accounts) {
    console.log("Setting variables")
    // planId = 0x28e0000000000000000000000000000000000000000000000000000000000000
    // planName = "Test plan"
    // termsAndConditionsHash = 0x20e0000000000000000000000000000000000000000000000000000000000000
    // joiningPeriod = 10
    // deductionFactors0 = [1,2,4,6]
    // deductionFactors1 = [2,4,8,12]
    // deductionFactors2 = [3,6,12,18]
    // deductionFactors3 = [4,8,16,24]
    // deductionFactors4 = [5,10,20,30]
    // deductionFactors5 = [6,12,24,36]
    // deductionFactors6 = [7,14,28,42]
    // deductionFactors7 = [8,16,32,48]
    // lowerAgeLimits = [0, 36, 51, 56]
    // upperAgeLimits = [35, 50, 55, 60]
    oneDay = 60*60*24
    }

async function deployLibs(deployer, network, accounts) {
    console.log("Deploying libraries")
    await deployer.deploy(Migrations);
    await deployer.deploy(organLibrary);
    await deployer.deploy(procedureLibrary);
    await deployer.deploy(propositionVotingLibrary);

    // await deployer.deploy(SubscriptionManagementLib);
    // await deployer.deploy(ClaimsAndRecoursesManagementLib);
    await deployer.link(organLibrary, [Organ]);
    await deployer.link(propositionVotingLibrary, [voteOnAdminsAndMastersProcedure]);
    await deployer.link(propositionVotingLibrary, [generalAssemblyProcedure]);
    await deployer.link(procedureLibrary, [simpleNormNominationProcedure]);
    await deployer.link(procedureLibrary, [voteOnAdminsAndMastersProcedure]);
    await deployer.link(procedureLibrary, [generalAssemblyProcedure]);
    // await deployer.link(SubscriptionManagementLib, [BihuInsurance]);
    // await deployer.link(ClaimsAndRecoursesManagementLib, [BihuInsurance]);


  }

async function declareOrgans(deployer, network, accounts) {
    console.log("Declaring organs")
    // Declaring operationnal organs
    Associes = await Organ.new(web3.utils.fromAscii("Associes"), {from: accounts[0]});
    respJuridique = await Organ.new(web3.utils.fromAscii("respJuridique"), {from: accounts[0]});
    docJuridiques = await Organ.new(web3.utils.fromAscii("docJuridiques"), {from: accounts[0]});
    statuts = await Organ.new(web3.utils.fromAscii("statuts"), {from: accounts[0]});
    Presidence = await Organ.new(web3.utils.fromAscii("Presidence"), {from: accounts[0]});
    respRH = await Organ.new(web3.utils.fromAscii("respRH"), {from: accounts[0]});
    registreDuPersonnel = await Organ.new(web3.utils.fromAscii("registreDuPersonnel"), {from: accounts[0]});
    decisionsAssocies = await Organ.new(web3.utils.fromAscii("decisionsAssocies"), {from: accounts[0]});
    directionGenerale = await Organ.new(web3.utils.fromAscii("directionGenerale"), {from: accounts[0]});
    respCompta = await Organ.new(web3.utils.fromAscii("respCompta"), {from: accounts[0]});
    registreComptable = await Organ.new(web3.utils.fromAscii("registreComptable"), {from: accounts[0]});
    p0ProposerProcedure = await Organ.new(web3.utils.fromAscii("p0ProposerProcedure"), {from: accounts[0]});
 
  }

async function declareProcedures(deployer, network, accounts) {
    console.log("Declaring procedures")
    p2 = await simpleNormNominationProcedure.new(directionGenerale.address, web3.utils.fromAscii("P2"), {from: accounts[0]});
    p3 = await simpleNormNominationProcedure.new(respJuridique.address, web3.utils.fromAscii("P3"), {from: accounts[0]});
    p4 = await simpleNormNominationProcedure.new(respRH.address, web3.utils.fromAscii("P4"), {from: accounts[0]});
    p5 = await simpleNormNominationProcedure.new(respCompta.address, web3.utils.fromAscii("P5"), {from: accounts[0]});

    //P1b voteOnAdminsAndMastersProcedure
    // constructor(address _votersOrganContract, address _membersWithVetoOrganContract, address _finalPromulgatorsOrganContract, uint _quorumSize, uint _votingPeriodDuration, uint _promulgationPeriodDuration, uint _majoritySize, string _name) 
    p1b = await voteOnAdminsAndMastersProcedure.new(Associes.address, Presidence.address, Presidence.address, p0ProposerProcedure.address, 30, 1*oneDay, 0, 50, web3.utils.fromAscii("P1B"), {from: accounts[0]});
    // constructor(address payable presidentOrganContract, address payable propositionVotingProcedure, uint _normalAssemblyDelay, uint _timeToPropose, bytes32 _name) 

    p1a = await generalAssemblyProcedure.new(Presidence.address, p1b.address, 365*oneDay, 1*oneDay, web3.utils.fromAscii("P1A"), {from: accounts[0]});

    }

async function setOrganAdminsAndMasters(deployer, network, accounts) {
    console.log("Setting organ parameters")
    // Setting Masters
    console.log("Setting masters")
    await Associes.addMaster(p1b.address, true, true, {from: accounts[0]});
    await respJuridique.addMaster(p1b.address, true, true, {from: accounts[0]});
    await docJuridiques.addMaster(p1b.address, true, true, {from: accounts[0]});
    await statuts.addMaster(p1b.address, true, true, {from: accounts[0]});
    await Presidence.addMaster(p1b.address, true, true, {from: accounts[0]});
    await respRH.addMaster(p1b.address, true, true, {from: accounts[0]});
    await registreDuPersonnel.addMaster(p1b.address, true, true, {from: accounts[0]});
    await decisionsAssocies.addMaster(p1b.address, true, true, {from: accounts[0]});
    await directionGenerale.addMaster(p1b.address, true, true, {from: accounts[0]});
    await respCompta.addMaster(p1b.address, true, true, {from: accounts[0]});
    await registreComptable.addMaster(p1b.address, true, true, {from: accounts[0]});
    await p0ProposerProcedure.addMaster(p1b.address, true, true, {from: accounts[0]});

    // Setting admins, operationnal organs
    console.log("Setting admins")
    await Associes.addAdmin(p1b.address, true, true, false, false, {from: accounts[0]});
    await respJuridique.addAdmin(p2.address, true, true, false, false, {from: accounts[0]});
    await docJuridiques.addAdmin(p3.address, true, true, false, false, {from: accounts[0]});
    await statuts.addAdmin(p1b.address, true, true, false, false, {from: accounts[0]});
    await Presidence.addAdmin(p1b.address, true, true, false, false, {from: accounts[0]});
    await respRH.addAdmin(p2.address, true, true, false, false, {from: accounts[0]});
    await registreDuPersonnel.addAdmin(p4.address, true, true, false, false, {from: accounts[0]});
    await decisionsAssocies.addAdmin(p1b.address, true, true, false, false, {from: accounts[0]});
    await directionGenerale.addAdmin(p1b.address, true, true, false, false, {from: accounts[0]});
    await respCompta.addAdmin(p2.address, true, true, false, false, {from: accounts[0]});
    await registreComptable.addAdmin(p5.address, true, true, false, false, {from: accounts[0]});
    await p0ProposerProcedure.addAdmin(p1b.address, true, true, false, false, {from: accounts[0]});


    // Setting temps admins
    console.log("Setting temp admins")
    await Presidence.addAdmin(accounts[0], true, true, true, true, {from: accounts[0]});

    }

async function setOrganNorms(deployer, network, accounts) 
    {
    // Setting norms
    console.log("Setting norms");
    await Presidence.addNorm("0x6E5329026eB58d6242A2633871a063464B098C7A", web3.utils.fromAscii("0"), 0, 0, {from: accounts[0]});

    }

async function cleanInstallation(deployer, network, accounts) 
    {
    console.log("Cleaning installation")


    // Removing temp admins
    console.log("Removing temp admins")
    await Presidence.remAdmin(accounts[0], {from: accounts[0]});
 

    // Removing temp masters
    console.log("Removing temp masters")
    await Associes.remMaster(accounts[0], {from: accounts[0]});
    await respJuridique.remMaster(accounts[0], {from: accounts[0]});
    await docJuridiques.remMaster(accounts[0], {from: accounts[0]});
    await statuts.remMaster(accounts[0], {from: accounts[0]});
    await Presidence.remMaster(accounts[0], {from: accounts[0]});
    await respRH.remMaster(accounts[0], {from: accounts[0]});
    await registreDuPersonnel.remMaster(accounts[0], {from: accounts[0]});
    await decisionsAssocies.remMaster(accounts[0], {from: accounts[0]});
    await directionGenerale.remMaster(accounts[0], {from: accounts[0]});
    await respCompta.remMaster(accounts[0], {from: accounts[0]});
    await registreComptable.remMaster(accounts[0], {from: accounts[0]});
    await p0ProposerProcedure.remMaster(accounts[0], {from: accounts[0]});
    }

async function installationRecap(deployer, network, accounts){
        console.log("Migration finished")
        console.log("Organs")
        console.log("    \""+Associes.address+"\",  // (Associes)")
        console.log("    \""+respJuridique.address+"\",  // (respJuridique)")
        console.log("    \""+docJuridiques.address+"\",  // (docJuridiques)")
        console.log("    \""+statuts.address+"\",  // (statuts)")
        console.log("    \""+Presidence.address+"\",  // (Presidence)")
        console.log("    \""+respRH.address+"\",  // (respRH)")
        console.log("    \""+registreDuPersonnel.address+"\",  // (registreDuPersonnel)")
        console.log("    \""+decisionsAssocies.address+"\",  // (decisionsAssocies)")
        console.log("    \""+directionGenerale.address+"\",  // (directionGenerale)")
        console.log("    \""+respCompta.address+"\",  // (respCompta)")
        console.log("    \""+registreComptable.address+"\",  // (registreComptable)")
        console.log("    \""+p0ProposerProcedure.address+"\",  // (p0ProposerProcedure)")
        console.log("Procedures")
        console.log("    \""+p1a.address+"\",  // (p1a)")
        console.log("    \""+p1b.address+"\",  // (p1b)")
        console.log("    \""+p2.address+"\",  // (p2)")
        console.log("    \""+p3.address+"\",  // (p3)")
        console.log("    \""+p4.address+"\",  // (p4)")
        console.log("    \""+p5.address+"\",  // (p5)")
        console.log("User roles")
        console.log("    0x6E5329026eB58d6242A2633871a063464B098C7A  // (President)")


}