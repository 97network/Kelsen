/// Importing required contracts
// Organs
var deployOrgan = artifacts.require("deployOrgan")
var Organ = artifacts.require("Organ")
// Cooptation
var deployNormsCooptationProcedure = artifacts.require("deploy/deployNormsCooptationProcedure")
var normsCooptationProcedure = artifacts.require("procedures/normsCooptationProcedure")




module.exports = function(deployer, network, accounts) {

  console.log("---------------------------------------------------------------------------------------------------------------")
  console.log("Testing Cooptation procedure")
  console.log("---------------------------------------------------------------------------------------------------------------")
  console.log("-------------------------------------")
  console.log("Available accounts : ")
  accounts.forEach((account, i) => console.log("-", account))
  console.log("-------------------------------------")
  console.log("-------------------------------------")
  console.log("Deploying Organ")
  // 1 organs to deploy: Members list
  deployer.deploy(deployOrgan, "Member Organ", {from: accounts[0]}).then(() => {
  const memberRegistryOrgan = Organ.at(deployOrgan.address)
    console.log("-------------------------------------")
    console.log("Deploying Cooptation procedure")

    // Voting time variables. These are short for demonstration purposes
    voteDurationInSeconds = 180
    // Deploy Cooptation
    deployer.deploy(deployNormsCooptationProcedure, memberRegistryOrgan.address, memberRegistryOrgan.address , memberRegistryOrgan.address, 60, voteDurationInSeconds, voteDurationInSeconds, "Cooptation",{from: accounts[0]}).then(() => {
    const cooptationProcedure = normsCooptationProcedure.at(deployNormsCooptationProcedure.address)

      console.log("-------------------------------------")
      console.log("Adding admin")
      memberRegistryOrgan.addAdmin(accounts[0], true, true, false, false, "Account 0", {from: accounts[0]}).then(() => {
      memberRegistryOrgan.addAdmin(cooptationProcedure.address, true, true, true, true, "Cooptation procedure", {from: accounts[0]}).then(() => {

        console.log("-------------------------------------")
        console.log("Adding norm")
        memberRegistryOrgan.addNorm(accounts[0], "Member 0", 1, 1, 1, {from: accounts[0]}).then(() => {
        memberRegistryOrgan.addNorm(accounts[1], "Member 1", 1, 1, 1, {from: accounts[0]}).then(() => {
              
          console.log("-------------------------------------")
          console.log("Set up is finished! Account[0] is now a norm of member registry.")
          console.log("-------------------------------------")
            console.log("Retrieving procedure info")
            cooptationProcedure.quorumSize({from: accounts[0]}).then(quorumSize_r => {
              console.log(quorumSize_r)
              cooptationProcedure.createProposition("Ac1", 0,0,0,{from: accounts[2], value: 1000000000}).then(() => {
                cooptationProcedure.getPropositionDetails(0).then(prop_det => {
                  console.log(prop_det)
                  memberRegistryOrgan.getActiveNormNumber().then(mem_num => {
                    console.log(mem_num)
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
