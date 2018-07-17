

/// Importing required contracts
// Organs
var deployOrgan = artifacts.require("deployOrgan")
var Organ = artifacts.require("Organ")

// Cooptation
var deployNormsCooptationProcedure = artifacts.require("deploy/deployNormsCooptationProcedure")
var normsCooptationProcedure = artifacts.require("procedures/normsCooptationProcedure")

// Vote on member addition
var deployVoteOnNormsProcedure = artifacts.require("deploy/deployVoteOnNormsProcedure")
var voteOnNormsProcedure = artifacts.require("procedures/voteOnNormsProcedure")

// Vote on masters
var deployVoteOnAdminsAndMastersProcedure = artifacts.require("deploy/deployVoteOnAdminsAndMastersProcedure")
var voteOnAdminsAndMastersProcedure = artifacts.require("procedures/voteOnAdminsAndMastersProcedure")


module.exports = function(deployer, network, accounts) {
  console.log("-------------------------------------")
  console.log("Available accounts : ")
  accounts.forEach((account, i) => console.log("-", account))
  console.log("-------------------------------------")
  console.log("-------------------------------------")
  console.log("Deploying Organs")
  console.log("-------------------------------------")
  // Creating Bureau organ
  deployer.deploy(deployOrgan, "Bureau", {from: accounts[0]}).then(() => {
  const bureauOrgan = Organ.at(deployOrgan.address)

  // Creating Members organ
  deployer.deploy(deployOrgan, "Membres", {from: accounts[0]}).then(() => {
  const membersOrgan = Organ.at(deployOrgan.address)
    console.log("-------------------------------------")
    console.log("Deploying Procedures")
    console.log("-------------------------------------")
    const threeMinutes = 60*3
    const twoDays = 60*60*24*2
    const twoWeeks = 60*60*24*7*2
    // Cooptation procedure (adding members)
    deployer.deploy(deployNormsCooptationProcedure, membersOrgan.address, bureauOrgan.address, bureauOrgan.address, 40, threeMinutes, threeMinutes, "Cooptation des membres", {from: accounts[0]}).then(() => {
    const cooptation = normsCooptationProcedure.at(deployNormsCooptationProcedure.address)

    // Vote On norms (excluding members)
    deployer.deploy(deployVoteOnNormsProcedure, membersOrgan.address, bureauOrgan.address, 0x0000, 0x0000, 100, twoDays, 0, 100, "Exclusion de membres", {from: accounts[0]}).then(() => {
    const memberExclusion = voteOnNormsProcedure.at(deployVoteOnNormsProcedure.address)

    // Vote on norms (replacing bureau)
    deployer.deploy(deployVoteOnNormsProcedure, bureauOrgan.address, bureauOrgan.address, 0x0000, 0x0000, 65, twoDays, 0, 65, "Renouvellement du bureau", {from: accounts[0]}).then(() => {
    const bureauReplacement = voteOnNormsProcedure.at(deployVoteOnNormsProcedure.address)

    // Vote on admins (modify DAO architecture)
    deployer.deploy(deployVoteOnAdminsAndMastersProcedure, membersOrgan.address, bureauOrgan.address, 0x0000, 60, twoWeeks, 0, 65, "Changement des statuts", {from: accounts[0]}).then(() => {
    const constitutionnalReform = voteOnAdminsAndMastersProcedure.at(deployVoteOnAdminsAndMastersProcedure.address)
      console.log("-------------------------------------")
      console.log("Set Admins")
      console.log("-------------------------------------")
      membersOrgan.addAdmin(cooptation.address, true, false, true, true, "Cooptation procedure", {from: accounts[0]}).then(() => {
      membersOrgan.addAdmin(memberExclusion.address, false, true, false, false , "Member exclusion",  {from: accounts[0]}).then(() => {
      bureauOrgan.addAdmin(bureauReplacement.address, true, true, false, false, "Bureau replacement", {from: accounts[0]}).then(() => {
        console.log("-------------------------------------")
        console.log("Set Masters")
        console.log("-------------------------------------")
        bureauOrgan.addMaster(constitutionnalReform.address, true, true, "Constitutionnal Reform", {from: accounts[0]}).then(() => {
        membersOrgan.addMaster(constitutionnalReform.address, true, true, "Constitutionnal Reform", {from: accounts[0]}).then(() => {
          console.log("-------------------------------------")
          console.log("Set temp Admin")
          console.log("-------------------------------------")
          membersOrgan.addAdmin(accounts[0], true, true, false, false , "Temp admin",  {from: accounts[0]}).then(() => {
          bureauOrgan.addAdmin(accounts[0], true, true, false, false, "Temp admin", {from: accounts[0]}).then(() => {
            console.log("-------------------------------------")
            console.log("Populate Bureau")
            console.log("-------------------------------------")
            // bureauOrgan.addNorm(address, name, ipfsHash, hash_Function, size, {from: accounts[0]}).then(() => {
              console.log("-------------------------------------")
              console.log("Populate members list")
              console.log("-------------------------------------")
              // membersOrgan.addNorm(address, name, ipfsHash, hash_Function, size, {from: accounts[0]}).then(() => {
                console.log("-------------------------------------")
                console.log("Remove temp Admins")
                console.log("-------------------------------------")
                membersOrgan.remAdmin(accounts[0],  {from: accounts[0]}).then(() => {
                bureauOrgan.remAdmin(accounts[0], {from: accounts[0]}).then(() => {
                  console.log("-------------------------------------")
                  console.log("Remove temp Master")
                  console.log("-------------------------------------")
                    membersOrgan.remMaster(accounts[0],  {from: accounts[0]}).then(() => {
                    bureauOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {

                    console.log("-------------------------------------")
                    console.log("System has been deployed.")
                    console.log("Organs are:")
                    console.log("    \""+membersOrgan.address+"\",  // (Members organ)")
                    console.log("    \""+bureauOrgan.address+"\",  // (Bureau organ)")
                    console.log("Procedures are:")
                    console.log("    \""+cooptation.address+"\",  // (Cooptation procedure)")
                    console.log("    \""+memberExclusion.address+"\",  // (Member Exclusion procedure)")
                    console.log("    \""+bureauReplacement.address+"\",  // (Bureau replacement procedure)")
                    console.log("    \""+constitutionnalReform.address+"\",  // (Constitutionnal reform procedure)")

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

          

}
