




/// Importing required contracts
// Organs
var deployOrgan = artifacts.require("deployOrgan")
var Organ = artifacts.require("Organ")
// Deposit Funds procedure
var deployDepositFundsProcedure = artifacts.require("deploy/deployDepositWithdrawFundsProcedure")
var depositFundsProcedure = artifacts.require("procedures/depositWithdrawFundsProcedure")
// Vote on masters
var deployVoteOnAdminsAndMastersProcedure = artifacts.require("deploy/deployVoteOnAdminsAndMastersProcedure")
var voteOnAdminsAndMastersProcedure = artifacts.require("procedures/voteOnAdminsAndMastersProcedure")
// Vote on member addition
var deployVoteOnNormsProcedure = artifacts.require("deploy/deployVoteOnNormsProcedure")
var voteOnNormsProcedure = artifacts.require("procedures/voteOnNormsProcedure")
// Vote on expense
var deployVoteOnExpenseProcedure = artifacts.require("deploy/deployVoteOnExpenseProcedure")
var voteOnExpenseProcedure = artifacts.require("procedures/voteOnExpenseProcedure")



module.exports = function(deployer, network, accounts) {

  console.log("---------------------------------------------------------------------------------------------------------------")
  console.log("Deploying a participatory budget")
  console.log("---------------------------------------------------------------------------------------------------------------")
  console.log("-------------------------------------")
  console.log("Available accounts : ")
  accounts.forEach((account, i) => console.log("-", account))
  console.log("-------------------------------------")
  console.log("Initial balance:")
  console.log(web3.eth.getBalance(accounts[0]).toString(10))
  console.log("-------------------------------------")
  console.log("Deploying Organ")
  // 1 organs to deploy: Members list
  deployer.deploy(deployOrgan, "Member Organ", {from: accounts[0]}).then(() => {
  const memberRegistryOrgan = Organ.at(deployOrgan.address)
    console.log("-------------------------------------")
    console.log("Deploying Procedures")
    // Deploying 4 procedures: 
    // * Vote on adding/excluding members
    // * Vote on changing constitution
    // * Vote on expense
    // * Deposit procedure
    // Voting time variables. These are short for demonstration purposes
    voteDurationInSeconds = 30
    
    // Deploy members list management
    deployer.deploy(deployVoteOnNormsProcedure, memberRegistryOrgan.address, memberRegistryOrgan.address, 0x0000 , memberRegistryOrgan.address, 40, voteDurationInSeconds, voteDurationInSeconds, 50, "Members list management", {from: accounts[0]}).then(() => {
    const memberManagement = voteOnNormsProcedure.at(deployVoteOnNormsProcedure.address)

    // Deploy constitutionnal reform procedure
    deployer.deploy(deployVoteOnAdminsAndMastersProcedure, memberRegistryOrgan.address, 0x0000, memberRegistryOrgan.address, 40, voteDurationInSeconds, voteDurationInSeconds, 66, "Constitutional reform", {from: accounts[0]}).then(() => {
    const constitutionnalReform = voteOnAdminsAndMastersProcedure.at(deployVoteOnAdminsAndMastersProcedure.address)

    // Deploy Vote on expense
    deployer.deploy(deployVoteOnExpenseProcedure, memberRegistryOrgan.address, memberRegistryOrgan.address, 0x0000,  memberRegistryOrgan.address, 40, voteDurationInSeconds, voteDurationInSeconds, 50, "Vote on expenses", {from: accounts[0]}).then(() => {
    const voteOnExpense = voteOnExpenseProcedure.at(deployVoteOnExpenseProcedure.address)

    // Deploy deposit procedure
    deployer.deploy(deployDepositFundsProcedure, 0x0000, 0x0000, memberRegistryOrgan.address, "Depositing", {from: accounts[0]}).then(() => {
    const depositFunds = depositFundsProcedure.at(deployDepositFundsProcedure.address)

      console.log("-------------------------------------")
      console.log("Crediting masters")
      memberRegistryOrgan.addMaster(constitutionnalReform.address, true, true, "Constitutionnal reform", {from: accounts[0]}).then(() => {

        console.log("-------------------------------------")
        console.log("Crediting admins")

        memberRegistryOrgan.addAdmin(memberManagement.address, true, true, false, false, "Member cooptation", {from: accounts[0]}).then(() => {
        memberRegistryOrgan.addAdmin(voteOnExpense.address, false, false, false, true, "Voting on expenses", {from: accounts[0]}).then(() => {
        memberRegistryOrgan.addAdmin(depositFunds.address, false, false, true, false, "Deposit procedure", {from: accounts[0]}).then(() => {
        // Temp admin, in order to add members
        memberRegistryOrgan.addAdmin(accounts[0], true, true, false, false, "Temp admin", {from: accounts[0]}).then(() => {
          console.log("-------------------------------------")
          console.log("Crediting norms")
          memberRegistryOrgan.addNorm(accounts[0], "Member 0", 1, 1, 1, {from: accounts[0]}).then(() => {

            console.log("-------------------------------------")
            console.log("Removing temp admins")
            memberRegistryOrgan.remAdmin(accounts[0], {from: accounts[0]}).then(() => {
              console.log("-------------------------------------")
              console.log("Removing temp masters")
              memberRegistryOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {

                      // Set up is ready
                      
                // console.log("Test name display")
                // memberManagement.getProcedureName().then(myInfos1 => {
                // constitutionnalReform.getProcedureName().then(myInfos2 => {
                // voteOnExpense.getProcedureName().then(myInfos3 => {
                // depositFunds.getProcedureName().then(myInfos4 => {
                  console.log("Test getLinkedOrgans display")
                  memberManagement.getLinkedOrgans().then(myInfos1 => {
                  constitutionnalReform.getLinkedOrgans().then(myInfos2 => {
                  voteOnExpense.getLinkedOrgans().then(myInfos3 => {
                  depositFunds.getLinkedOrgans().then(myInfos4 => {
                    
                    console.log(myInfos1)
                    console.log(myInfos2)
                    console.log(myInfos3)
                    console.log(myInfos4)


                      console.log("-------------------------------------")
                      console.log("Put these new addresses in settings :")
                      console.log("  \"organs_addresses\": [")
                      console.log("    \""+memberRegistryOrgan.address+"\",  // (Members)")
                      console.log("  ],")
                      console.log("  \"procedures_addresses\": [")
                      console.log("    \""+memberManagement.address+"\",  // (Member management)")
                      console.log("    \""+voteOnExpense.address+"\",  // (Voting on expenses)")
                      console.log("    \""+depositFunds.address+"\",  // (Depositing funds)")
                      console.log("    \""+constitutionnalReform.address+"\",  // (Constitutionnal reform)")
                      console.log("  ]")
                      console.log("Accounts 0 has been added as members")
                      console.log("-------------------------------------")
                      console.log("Final balance:")
                      console.log(web3.eth.getBalance(accounts[0]).toString(10))
                      // console.log("Testing deposits")
                      // console.log(web3.eth.getBalance(memberRegistryOrgan.address).toString(10))
                      
                      //   depositFunds.sendTransaction({from: accounts[0], value: 1000000000}).then(() => {
                      //   console.log(web3.eth.getBalance(memberRegistryOrgan.address).toString(10))
                        
                      //   console.log("Testing Withdrawals")
                      //   voteOnExpense.createProposition(accounts[1], 1000, 1, 1, 1, "Test", {from: accounts[0]}).then(() => {
                      //   voteOnExpense.vote(0, true, {from: accounts[0]}).then(() => {
                      //   setTimeout(() => {
                      //   voteOnExpense.endPropositionVote(0, {from: accounts[0]}).then(() => {
                      //   console.log(web3.eth.getBalance(memberRegistryOrgan.address).toString(10))
                        
                      //   memberRegistryOrgan.getActiveNormNumber().then(normNumber => {
                      //   console.log(normNumber)
                        
                      //   voteOnExpense.getVotedPropositionResults(0).then(QueryResult => {
                      //   console.log(QueryResult)
                      //   voteOnExpense.getPropositionStatus(0).then(QueryResult => {
                      //   console.log(QueryResult)
                      //   voteOnExpense.getVotedPropositionStats(0).then(QueryResult => {
                      //   console.log(QueryResult)
                      //   console.log("promulgateProposition")
                      //   voteOnExpense.promulgateProposition(0, true, {from: accounts[0]}).then(() => {

                      //   console.log(web3.eth.getBalance(accounts[1]).toString(10))

                      //   }) // Promulgation
                      //   }) // Query election stats
                      //   }) // Query Election results
                      //   }) // Query status
                      //   }) // Get Norm Number
                      //   }) // End proposition
                      //   }, (voteDurationInSeconds+1)*1000) // Timeout
                      //   }) //Voting
                      //   }) // Proposition creation transaction
                      // }) // Deposit transaction







                      // Set up end

                                                                                      })
                                                                                    })
                                                                                  })
                                                                                })
                                                                              })
                                                                            })
                                                                          })
                                                                        })
                                                                      })
                                                                    })
                                                                  })
                                                                })
                                                              })
})})})})

  // Use deployer to state migration tasks.
};
