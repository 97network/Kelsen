var Migrations = artifacts.require("./Migrations.sol")
var deployOrgan = artifacts.require('deployOrgan')
var deploySimpleNormNominationProcedure = artifacts.require("deploySimpleNormNominationProcedure")
var deploySimpleAdminsAndMasterNominationProcedure = artifacts.require("deploySimpleAdminsAndMasterNominationProcedure")

async function _deployOrgan(name, from) {
    return deployOrgan.new(name, { from })
    .then(data => {
        console.log("Deployed organ", name, data.address)
        return data
    })
    .catch(console.error)
}

async function _deployProcedurePromise(promise, name = "") {
    return promise
    .then(data => {
        console.log("Deployed procedure", name, data.address)
        return data
    })
    .catch(console.error)
}

async function _removeMaster(organ, address, from) {
    return organ.remMaster(address, { from })
    .then(_ => console.log("Removed master", organ.address, address))
}

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        const from = accounts[0]

        console.log("### Deploying libraries")
        await deployer.deploy(Migrations)

        console.log("### Declaring organs")
        const directionGenerale = await _deployOrgan("Direction générale", from)
        const registreDuPersonnel = await _deployOrgan("Registre du personnel", from)
        const registreJuridique = await _deployOrgan("Documents juridiques", from)
        const registresComptables = await _deployOrgan("Registres comptables", from)

        console.log("### Declaring procedures")
        const nominateDirector = await _deployProcedurePromise(
          deploySimpleNormNominationProcedure.new(directionGenerale.address, "Nomination du directeur général", { from }),
          "Nomination du directeur général"
        )
        const updateRegistry = await _deployProcedurePromise(
          deploySimpleNormNominationProcedure.new(directionGenerale.address, "Édition des registres obligatoires", { from }),
          "Édition des registres obligatoires"
        )
        // P0 : Administer system
        const administerSystem = await _deployProcedurePromise(
          deploySimpleAdminsAndMasterNominationProcedure.new(directionGenerale.address, "Modification du système", { from }),
          "Modification du système"
        )

        console.log("### Setting organ parameters.")

        console.log("### Adding masters")
        await directionGenerale.addMaster(administerSystem.address, true, true, "Modification du système", { from })
        .then(_ => console.log("Added Master", directionGenerale.address, administerSystem.address))
        await registreDuPersonnel.addMaster(administerSystem.address, true, true, "Modification du système", { from })
        .then(_ => console.log("Added Master", registreDuPersonnel.address, administerSystem.address))
        await registreJuridique.addMaster(administerSystem.address, true, true, "Modification du système", { from })
        .then(_ => console.log("Added Master", registreJuridique.address, administerSystem.address))
        await registresComptables.addMaster(administerSystem.address, true, true, "Modification du système", { from })
        .then(_ => console.log("Added Master", registresComptables.address, administerSystem.address))
        
        console.log("### Adding admins")
        await directionGenerale.addAdmin(nominateDirector.address, true, true, false, false, "Nomination du directeur général", { from })
        .then(_ => console.log("Added Admin", directionGenerale.address, nominateDirector.address))
        await registreJuridique.addAdmin(updateRegistry.address, true, true, false, false, "Édition des registres obligatoires", { from })
        .then(_ => console.log("Added Admin", registreJuridique.address, updateRegistry.address))
        await registreDuPersonnel.addAdmin(updateRegistry.address, true, true, false, false, "Édition des registres obligatoires", { from })
        .then(_ => console.log("Added Admin", registreDuPersonnel.address, updateRegistry.address))
        await registresComptables.addAdmin(updateRegistry.address, true, true, false, false, "Édition des registres obligatoires", { from })
        .then(_ => console.log("Added Admin", registresComptables.address, updateRegistry.address))

        console.log("### Adding temp admins")
        await directionGenerale.addAdmin(from, true, true, false, false, "Account 0", { from })
        .then(_ => console.log("Added Temp Admin Account 0", directionGenerale.address, from))
        
        console.log("### Adding entries");
        await directionGenerale.addNorm(from, "Account 0", "0x", 0, 0, { from })
        .then(_ => console.log("Added entry", directionGenerale.address, from))

        console.log("### Cleaning installation")
        await directionGenerale.remAdmin(from, { from })
        .then(_ => console.log("Removed temp admin", directionGenerale.address, from))

        console.log("### Removing temp masters")
        await _removeMaster(directionGenerale, from, from)
        await _removeMaster(registreDuPersonnel, from, from)
        await _removeMaster(registreJuridique, from, from)
        await _removeMaster(registresComptables, from, from)

        console.log("##########################")
        console.log("### Migration finished ###")
        console.log("[")
        console.log("  \""+directionGenerale.address+"\",  // [Organ] Direction générale")
        console.log("  \""+registreDuPersonnel.address+"\",  // [Organ] Registre du personnel")
        console.log("  \""+registreJuridique.address+"\",  // [Organ] Documents juridiques")
        console.log("  \""+registresComptables.address+"\",  // [Organ] Registres comptables")
        console.log("  \""+administerSystem.address+"\",  // [Procedure] p0 Modification du système")
        console.log("  \""+nominateDirector.address+"\",  // [Procedure] p1 Nomination du directeur général")
        console.log("  \""+updateRegistry.address+"\",  // [Procedure] p2 Édition des registres obligatoires")
        console.log("]")
    })
}