

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
  console.log("Deploying a group of registries to manage a French SAS")
  console.log("---------------------------------------------------------------------------------------------------------------")
  console.log("-------------------------------------")
  console.log("Available accounts : ")
  accounts.forEach((account, i) => console.log("-", account))
  console.log("-------------------------------------")
  console.log("-------------------------------------")
  console.log("Deploying Organ")
  // 5 organs to deploy
  deployer.deploy(deployOrgan, "Registre des actionnaires", {from: accounts[0]}).then(() => {
  const actionnairesOrgan = Organ.at(deployOrgan.address)
  deployer.deploy(deployOrgan, "Registre des décisions des actionnaires", {from: accounts[0]}).then(() => {
  const decisionsActionnairesOrgan = Organ.at(deployOrgan.address)
  deployer.deploy(deployOrgan, "Registre du personnel", {from: accounts[0]}).then(() => {
  const personnelOrgan = Organ.at(deployOrgan.address)
  deployer.deploy(deployOrgan, "Livre comptable", {from: accounts[0]}).then(() => {
  const livreComptableOrgan = Organ.at(deployOrgan.address)
  deployer.deploy(deployOrgan, "Registre des mouvements de titres", {from: accounts[0]}).then(() => {
  const mouvementsDeTitresOrgan = Organ.at(deployOrgan.address)


    console.log("-------------------------------------")
    console.log("Deploying Procedures")
    // Deploying 6 procedures: 

    // Voting time variables. These are short for demonstration purposes
    voteDurationInSeconds = 3*24*60*60
    
    // Gestion des décisions des actionnaires
    deployer.deploy(deployVoteOnAdminsAndMastersProcedure, actionnairesOrgan.address, 0x0000, actionnairesOrgan.address, 50, voteDurationInSeconds, voteDurationInSeconds, 50, "Gestion des décisions", {from: accounts[0]}).then(() => {
    const addDecisionsActionnaires = voteOnAdminsAndMastersProcedure.at(deployVoteOnAdminsAndMastersProcedure.address)

    // Nomination du personnel
    deployer.deploy(deploySimpleNormNominationProcedure, actionnairesOrgan.address, "Gestion du personnel", {from: accounts[0]}).then(() => {
    const addPersonnel = simpleNormNominationProcedure.at(deploySimpleNormNominationProcedure.address)

    // Deploy statutory reform procedure
    deployer.deploy(deployVoteOnAdminsAndMastersProcedure, actionnairesOrgan.address, 0x0000, actionnairesOrgan.address, 50, voteDurationInSeconds, voteDurationInSeconds, 66, "Réforme des statuts", {from: accounts[0]}).then(() => {
    const constitutionnalReform = voteOnAdminsAndMastersProcedure.at(deployVoteOnAdminsAndMastersProcedure.address)

      console.log("-------------------------------------")
      console.log("Crediting masters")
      actionnairesOrgan.addMaster(constitutionnalReform.address, true, true, "Réforme des statuts", {from: accounts[0]}).then(() => {
      decisionsActionnairesOrgan.addMaster(constitutionnalReform.address, true, true, "Réforme des statuts", {from: accounts[0]}).then(() => {
      personnelOrgan.addMaster(constitutionnalReform.address, true, true, "Réforme des statuts", {from: accounts[0]}).then(() => {
      livreComptableOrgan.addMaster(constitutionnalReform.address, true, true, "Réforme des statuts", {from: accounts[0]}).then(() => {
      mouvementsDeTitresOrgan.addMaster(constitutionnalReform.address, true, true, "Réforme des statuts", {from: accounts[0]}).then(() => {

        console.log("-------------------------------------")
        console.log("Crediting admins")

        personnelOrgan.addAdmin(addPersonnel.address, true, true, false, false, "Gestion du personnel", {from: accounts[0]}).then(() => {
        actionnairesOrgan.addAdmin(addDecisionsActionnaires.address, true, true, false, false, "Gestion des actionnaires", {from: accounts[0]}).then(() => {
        decisionsActionnairesOrgan.addAdmin(addDecisionsActionnaires.address, true, true, false, false, "Gestion des décisions", {from: accounts[0]}).then(() => {
        livreComptableOrgan.addAdmin(addDecisionsActionnaires.address, true, true, false, false, "Gestion du livre comptable", {from: accounts[0]}).then(() => {
       	mouvementsDeTitresOrgan.addAdmin(addDecisionsActionnaires.address, true, true, false, false, "Gestion des mouvements de titres", {from: accounts[0]}).then(() => {

        // Temp admin, in order to add members
        actionnairesOrgan.addAdmin(accounts[0], true, true, false, false, "Temp admin", {from: accounts[0]}).then(() => {
          console.log("-------------------------------------")
          console.log("Crediting norms")
          actionnairesOrgan.addNorm("0x051C3f5788d868221C8636b08e86d80d143BeC2D", "Shareholder 1", 1, 1, 1, {from: accounts[0]}).then(() => {
          actionnairesOrgan.addNorm("0xc3a7897616Ae683089C737076e2751ADC9ecE481", "Shareholder 2", 1, 1, 1, {from: accounts[0]}).then(() => {

            console.log("-------------------------------------")
            console.log("Removing temp admins")
            actionnairesOrgan.remAdmin(accounts[0], {from: accounts[0]}).then(() => {
              console.log("-------------------------------------")
              console.log("Removing temp masters")
              actionnairesOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {
              decisionsActionnairesOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {
              personnelOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {
              livreComptableOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {
              mouvementsDeTitresOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {


                      console.log("-------------------------------------")
                      console.log("Put these new addresses in settings :")
                      console.log("  \"organs_addresses\": [")
                      console.log("    \""+actionnairesOrgan.address+"\",  // (actionnairesOrgan)")
                      console.log("    \""+decisionsActionnairesOrgan.address+"\",  // (decisionsActionnairesOrgan)")
                      console.log("    \""+personnelOrgan.address+"\",  // (personnelOrgan)")
                      console.log("    \""+livreComptableOrgan.address+"\",  // (livreComptableOrgan)")
                      console.log("    \""+mouvementsDeTitresOrgan.address+"\",  // (mouvementsDeTitresOrgan)")
                      console.log("  ],")
                      console.log("  \"procedures_addresses\": [")
                      console.log("    \""+addDecisionsActionnaires.address+"\",  // (addDecisionsActionnaires)")
                      console.log("    \""+addPersonnel.address+"\",  // (addPersonnel)")
                      console.log("    \""+constitutionnalReform.address+"\",  // (constitutionnalReform)")
            
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
