var Migrations = artifacts.require("./Migrations.sol")
var deployOrgan = artifacts.require('deployOrgan')
var deploySimpleNormNominationProcedure = artifacts.require("deploySimpleNormNominationProcedure")
var deploySimpleAdminsAndMasterNominationProcedure = artifacts.require("deploySimpleAdminsAndMasterNominationProcedure")

async function _deployOrgan(name) {
    return deployOrgan.new(name)
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

module.exports = (deployer, _network, accounts) => {
    deployer.then(async () => {
        console.log("\n### Deploying libraries")
        await deployer.deploy(Migrations)

        console.log("\n### Deploying organs")
        const [
            directionGenerale,
            registreDuPersonnel,
            registreJuridique,
            registresComptables
        ] = await Promise.all([
            _deployOrgan("Direction générale"),
            _deployOrgan("Registre du personnel"),
            _deployOrgan("Documents juridiques"),
            _deployOrgan("Registres comptables")
        ])

        console.log("\n### Deploying procedures")
        const [
            nominateDirector,
            updateRegistry,
            administerSystem
        ] = await Promise.all([
            _deployProcedurePromise(
                deploySimpleNormNominationProcedure.new(directionGenerale.address, "Nomination du directeur général"),
                "Nomination du directeur général"
            ),
            _deployProcedurePromise(
                deploySimpleNormNominationProcedure.new(directionGenerale.address, "Édition des registres obligatoires"),
                "Édition des registres obligatoires"
              ),
            _deployProcedurePromise(
                deploySimpleAdminsAndMasterNominationProcedure.new(directionGenerale.address, "Modification du système"),
                "Modification du système"
            )
        ])

        console.log("\n### Setting organ parameters.")
        await Promise.all([
            // Adding Masters
            directionGenerale.addMaster(administerSystem.address, true, true, "Administration de la Direction Générale")
            .then(_ => console.log("Added Master", directionGenerale.address, administerSystem.address)),
            registreDuPersonnel.addMaster(administerSystem.address, true, true, "Administration du Registre du Personnel")
            .then(_ => console.log("Added Master", registreDuPersonnel.address, administerSystem.address)),
            registreJuridique.addMaster(administerSystem.address, true, true, "Administration du Registre Juridique")
            .then(_ => console.log("Added Master", registreJuridique.address, administerSystem.address)),
            registresComptables.addMaster(administerSystem.address, true, true, "Administration du Registre Comptable")
            .then(_ => console.log("Added Master", registresComptables.address, administerSystem.address)),
            // Adding Admins
            directionGenerale.addAdmin(nominateDirector.address, true, true, false, false, "Nomination d'un Directeur Général")
            .then(_ => console.log("Added Admin", directionGenerale.address, nominateDirector.address)),
            registreJuridique.addAdmin(updateRegistry.address, true, true, false, false, "Édition d'un Document Juridique")
            .then(_ => console.log("Added Admin", registreJuridique.address, updateRegistry.address)),
            registreDuPersonnel.addAdmin(updateRegistry.address, true, true, false, false, "Gestion du Personnel")
            .then(_ => console.log("Added Admin", registreDuPersonnel.address, updateRegistry.address)),
            registresComptables.addAdmin(updateRegistry.address, true, true, false, false, "Édition d'un Registre Comptable")
            .then(_ => console.log("Added Admin", registresComptables.address, updateRegistry.address)),
            // Adding Temp Admins
            directionGenerale.addAdmin(accounts[0], true, true, false, false, "Administrator")
            .then(_ => console.log("Added Temp Administrator", directionGenerale.address, accounts[0]))
        ])

        console.log("\n### Adding entries");
        await directionGenerale.addNorm(accounts[0], "Directeur Général", "0x", 0, 0)
        .then(_ => console.log("Added entry", directionGenerale.address, accounts[0]))

        console.log("\n### Cleaning installation")
        await Promise.all([
            // Removing Temp Admins
            directionGenerale.remAdmin(accounts[0])
            .then(_ => console.log("Removed temp admin", directionGenerale.address, accounts[0])),
            // Removing Temp Masters
            directionGenerale.remMaster(accounts[0])
            .then(_ => console.log("Removed master", directionGenerale.address, accounts[0])),
            registreDuPersonnel.remMaster(accounts[0])
            .then(_ => console.log("Removed master", registreDuPersonnel.address, accounts[0])),
            registreJuridique.remMaster(accounts[0])
            .then(_ => console.log("Removed master", registreJuridique.address, accounts[0])),
            registresComptables.remMaster(accounts[0])
            .then(_ => console.log("Removed master", registresComptables.address, accounts[0])),
        ])

        console.log("\n##########################\n### Success!\n\n")
        console.log("[")
        console.log("   \""+directionGenerale.address+"\",    // [Organ] Direction générale")
        console.log("   \""+registreDuPersonnel.address+"\",    // [Organ] Registre du personnel")
        console.log("   \""+registreJuridique.address+"\",    // [Organ] Documents juridiques")
        console.log("   \""+registresComptables.address+"\",    // [Organ] Registres comptables")
        console.log("   \""+administerSystem.address+"\",    // [Procedure] p0 Modification du système")
        console.log("   \""+nominateDirector.address+"\",    // [Procedure] p1 Nomination du directeur général")
        console.log("   \""+updateRegistry.address+"\",    // [Procedure] p2 Édition des registres obligatoires")
        console.log("]")
    })
}