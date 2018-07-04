

/// Importing required contracts
// Organs
var deployOrgan = artifacts.require("deployOrgan")
var Organ = artifacts.require("Organ")

// Vote on masters
var deployVoteOnAdminsAndMastersProcedure = artifacts.require("deploy/deployVoteOnAdminsAndMastersProcedure")
var voteOnAdminsAndMastersProcedure = artifacts.require("procedures/voteOnAdminsAndMastersProcedure")

// Vote on member addition
var deployVoteOnNormsProcedure = artifacts.require("deploy/deployVoteOnNormsProcedure")
var voteOnNormsProcedure = artifacts.require("procedures/voteOnNormsProcedure")

// Simple Norm Nomination
var deploySimpleNormNominationProcedure = artifacts.require("deploy/deploySimpleNormNominationProcedure")
var simpleNormNominationProcedure = artifacts.require("procedures/simpleNormNominationProcedure")



module.exports = function(deployer, network, accounts) {

  console.log("---------------------------------------------------------------------------------------------------------------")
  console.log("Deploying an admin registry")
  console.log("---------------------------------------------------------------------------------------------------------------")
  console.log("-------------------------------------")
  console.log("Available accounts : ")
  accounts.forEach((account, i) => console.log("-", account))
  console.log("-------------------------------------")
  console.log("-------------------------------------")
  console.log("Deploying Organ")
  // 1 organs to deploy: Admins
  deployer.deploy(deployOrgan, "Admins", {from: accounts[0]}).then(() => {
  const adminOrgan = Organ.at(deployOrgan.address)


    console.log("-------------------------------------")
    console.log("Deploying Procedures")
    // Deploying 3 procedures: 
    // * Vote on adding/excluding members
    // * Vote on adding/excluding public registry entries
    // * Vote on changing constitution
    // Voting time variables. These are short for demonstration purposes
    voteDurationInSeconds = 3*24*60*60
    
    // Deploy members list management
    deployer.deploy(deployVoteOnNormsProcedure, adminOrgan.address, adminOrgan.address, 0x0000 , adminOrgan.address, 40, voteDurationInSeconds, voteDurationInSeconds, 50, "Admin management", {from: accounts[0]}).then(() => {
    const memberManagement = voteOnNormsProcedure.at(deployVoteOnNormsProcedure.address)

    // Deploy simple nomination procedure
    deployer.deploy(deploySimpleNormNominationProcedure, adminOrgan.address, "Member Nomination", {from: accounts[0]}).then(() => {
    const simpleNormNomination = simpleNormNominationProcedure.at(deploySimpleNormNominationProcedure.address)

    // Deploy constitutionnal reform procedure
    deployer.deploy(deployVoteOnAdminsAndMastersProcedure, adminOrgan.address, 0x0000, adminOrgan.address, 40, voteDurationInSeconds, voteDurationInSeconds, 66, "Admin constitutionnal reform", {from: accounts[0]}).then(() => {
    const constitutionnalReform = voteOnAdminsAndMastersProcedure.at(deployVoteOnAdminsAndMastersProcedure.address)

      console.log("-------------------------------------")
      console.log("Crediting masters")
      adminOrgan.addMaster(constitutionnalReform.address, true, true, "Admin constitutionnal reform", {from: accounts[0]}).then(() => {

        console.log("-------------------------------------")
        console.log("Crediting admins")

        adminOrgan.addAdmin(memberManagement.address, true, true, false, false, "Admin management", {from: accounts[0]}).then(() => {
        adminOrgan.addAdmin(simpleNormNomination.address, true, true, false, false, "Member addition", {from: accounts[0]}).then(() => {
        // Temp admin, in order to add members
        adminOrgan.addAdmin(accounts[0], true, true, false, false, "Temp admin", {from: accounts[0]}).then(() => {
          console.log("-------------------------------------")
          console.log("Crediting norms")
          adminOrgan.addNorm("0x208d0126D47B87aC070d3631655503526369F08f", "Henri", 1, 1, 1, {from: accounts[0]}).then(() => {

            console.log("-------------------------------------")
            console.log("Removing temp admins")
            adminOrgan.remAdmin(accounts[0], {from: accounts[0]}).then(() => {
              console.log("-------------------------------------")
              console.log("Removing temp masters")
              adminOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {

                      // Set up is ready
                console.log("Test name display")
                memberManagement.getProcedureName().then(myInfos1 => {
                constitutionnalReform.getProcedureName().then(myInfos2 => {
                simpleNormNomination.getProcedureName().then(myInfos3 => {
                    console.log(myInfos1)
                    console.log(myInfos2)
                    console.log(myInfos3)

                      console.log("-------------------------------------")
                      console.log("Put these new addresses in settings :")
                      console.log("  \"organs_addresses\": [")
                      console.log("    \""+adminOrgan.address+"\",  // (Admins)")
                      console.log("  ],")
                      console.log("  \"procedures_addresses\": [")
                      console.log("    \""+memberManagement.address+"\",  // (Admin management)")
                      console.log("    \""+simpleNormNomination.address+"\",  // (Simple nomination)")
                      console.log("    \""+constitutionnalReform.address+"\",  // (Admin constitutionnal reform)")
                      console.log("  ]")
                      console.log("Accounts 0 has been added as members")
                      console.log("-------------------------------------")

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
                                                            })



  // Use deployer to state migration tasks.
};
