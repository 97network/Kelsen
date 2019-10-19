/**
 * NOTE :
 * When deploying via Infura, the HDWalletProvider only gives access to 1 account.
 * accounts[1] is only usable in development and should be replaced when deploying live.
 * @See ACCOUNT_2.
 */

var Migrations = artifacts.require("./Migrations.sol")
var deployOrgan = artifacts.require('deployOrgan')
var deploySimpleNormNominationProcedure = artifacts.require("deploySimpleNormNominationProcedure")
var deployVoteOnAdminsAndMastersProcedure = artifacts.require("deployVoteOnAdminsAndMastersProcedure")
var generalAssemblyProcedure = artifacts.require("generalAssemblyProcedure")

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
        console.log("### Setting variables")
        const ONE_DAY = 60 * 60 * 24
        const from = accounts[0]
        const ACCOUNT_2 = accounts[1]
        if (!ACCOUNT_2)
            throw new Error("ACCOUNT_2 needs to be hardcoded.")

        console.log("### Deploying libraries")
        await deployer.deploy(Migrations)

        console.log("### Declaring organs")
        const associates = await _deployOrgan("Associés", from)
        const respJuridique = await _deployOrgan("Responsable juridique", from)
        const docJuridiques = await _deployOrgan("Documentation juridique", from)
        const statuts = await _deployOrgan("Statuts", from)
        const presidency = await _deployOrgan("Présidence", from)
        const respRH = await _deployOrgan("Responsable RH", from)
        const registreDuPersonnel = await _deployOrgan("Registre du personnel", from)
        const decisionsAssocies = await _deployOrgan("Registre des décisions des associés", from)
        const directionGenerale = await _deployOrgan("Direction générale", from)
        const respCompta = await _deployOrgan("Responsable de la comptabilité", from)
        const registreComptable = await _deployOrgan("Registres comptables", from)
        const p0ProposerProcedure = await _deployOrgan("Associés ayant un pouvoir d'initiative", from)

        console.log("### Declaring procedures")
        const p2 = await _deployProcedurePromise(
            deploySimpleNormNominationProcedure.new(directionGenerale.address, "Nomination des directeurs.trices", { from }),
            "Nomination des directeurs.trices"
        )
        const p3 = await _deployProcedurePromise(
            deploySimpleNormNominationProcedure.new(respJuridique.address, "Gestion des documents juridiques", { from }),
            "Gestion des documents juridiques"
        )
        const p4 = await _deployProcedurePromise(
            deploySimpleNormNominationProcedure.new(respRH.address, "Édition du registre du personnel", { from }),
            "Édition du registre du personnel"
        )
        const p5 = await _deployProcedurePromise(
            deploySimpleNormNominationProcedure.new(respCompta.address, "Édition des registres comptables", { from }),
            "Édition des registres comptables"
        )
        const p1b = await _deployProcedurePromise(
            deployVoteOnAdminsAndMastersProcedure.new(associates.address, presidency.address, presidency.address, p0ProposerProcedure.address, 30, 1 * ONE_DAY, 0, 50, "Assemblée générale", { from }),
            "Assemblée générale"
        )
        const p1a = await _deployProcedurePromise(
            generalAssemblyProcedure.new(presidency.address, p1b.address, 365 * ONE_DAY, 1 * ONE_DAY, "Gestion d'assemblées générales", { from }),
            "Gestion d'assemblées générales"
        )

        console.log("### Setting organ parameters.")

        console.log("### Adding masters")
        await associates.addMaster(p1b.address, true, true, "Associés", { from })
        .then(_ => console.log("Added Master", associates.address, p1b.address))
        await respJuridique.addMaster(p1b.address, true, true, "Responsable juridique", { from })
        .then(_ => console.log("Added Master", respJuridique.address, p1b.address))
        await docJuridiques.addMaster(p1b.address, true, true, "Documentation juridique", { from })
        .then(_ => console.log("Added Master", docJuridiques.address, p1b.address))
        await statuts.addMaster(p1b.address, true, true, "Statuts", { from })
        .then(_ => console.log("Added Master", statuts.address, p1b.address))
        await presidency.addMaster(p1b.address, true, true, "Présidence", { from })
        .then(_ => console.log("Added Master", presidency.address, p1b.address))
        await respRH.addMaster(p1b.address, true, true, "Responsable RH", { from })
        .then(_ => console.log("Added Master", respRH.address, p1b.address))
        await registreDuPersonnel.addMaster(p1b.address, true, true, "Registre du personnel", { from })
        .then(_ => console.log("Added Master", registreDuPersonnel.address, p1b.address))
        await decisionsAssocies.addMaster(p1b.address, true, true, "Registre des décisions des associés", { from })
        .then(_ => console.log("Added Master", decisionsAssocies.address, p1b.address))
        await directionGenerale.addMaster(p1b.address, true, true, "Direction générale", { from })
        .then(_ => console.log("Added Master", directionGenerale.address, p1b.address))
        await respCompta.addMaster(p1b.address, true, true, "Responsable de la comptabilité", { from })
        .then(_ => console.log("Added Master", respCompta.address, p1b.address))
        await registreComptable.addMaster(p1b.address, true, true, "Registres comptables", { from })
        .then(_ => console.log("Added Master", registreComptable.address, p1b.address))
        await p0ProposerProcedure.addMaster(p1b.address, true, true, "Associés ayant un pouvoir d'initiative", { from })
        .then(_ => console.log("Added Master", p0ProposerProcedure.address, p1b.address))

        console.log("### Adding admins")
        await associates.addAdmin(p1b.address, true, true, false, false, "Associés", { from })
        .then(_ => console.log("Added Admin", associates.address, p1b.address))
        await respJuridique.addAdmin(p2.address, true, true, false, false, "Responsable juridique", { from })
        .then(_ => console.log("Added Admin", respJuridique.address, p2.address))
        await docJuridiques.addAdmin(p3.address, true, true, false, false, "Documentation juridique", { from })
        .then(_ => console.log("Added Admin", docJuridiques.address, p3.address))
        await statuts.addAdmin(p1b.address, true, true, false, false, "Statuts", { from })
        .then(_ => console.log("Added Admin", statuts.address, p1b.address))
        await presidency.addAdmin(p1b.address, true, true, false, false, "Présidence", { from })
        .then(_ => console.log("Added Admin", presidency.address, p1b.address))
        await respRH.addAdmin(p2.address, true, true, false, false, "Responsable RH", { from })
        .then(_ => console.log("Added Admin", respRH.address, p2.address))
        await registreDuPersonnel.addAdmin(p4.address, true, true, false, false, "Registre du personnel", { from })
        .then(_ => console.log("Added Admin", registreDuPersonnel.address, p4.address))
        await decisionsAssocies.addAdmin(p1b.address, true, true, false, false, "Registre des décisions des associés", { from })
        .then(_ => console.log("Added Admin", decisionsAssocies.address, p1b.address))
        await directionGenerale.addAdmin(p1b.address, true, true, false, false, "Direction générale", { from })
        .then(_ => console.log("Added Admin", directionGenerale.address, p1b.address))
        await respCompta.addAdmin(p2.address, true, true, false, false, "Responsable de la comptabilité", { from })
        .then(_ => console.log("Added Admin", respCompta.address, p2.address))
        await registreComptable.addAdmin(p5.address, true, true, false, false, "Registres comptables", { from })
        .then(_ => console.log("Added Admin", registreComptable.address, p5.address))
        await p0ProposerProcedure.addAdmin(p1b.address, true, true, false, false, "Associés ayant un pouvoir d'initiative", { from })
        .then(_ => console.log("Added Admin", p0ProposerProcedure.address, p1b.address))

        console.log("### Adding temp admins")
        await presidency.addAdmin(from, true, true, true, true, "temp", { from })
        .then(_ => console.log("Added Temp Admin", presidency.address, from))
        await associates.addAdmin(from, true, true, true, true, "temp", { from })
        .then(_ => console.log("Added Temp Admin", associates.address, from))
        
        console.log("### Adding entries");
        await presidency.addNorm(from, "Account 0", "0x", 0, 0, { from })
        .then(_ => console.log("Added entry", presidency.address, from))
        await associates.addNorm(ACCOUNT_2, "Account 1", "0x", 0, 0, { from })
        .then(_ => console.log("Added entry", associates.address, ACCOUNT_2))

        console.log("### Cleaning installation")
        await presidency.remAdmin(from, { from })
        .then(_ => console.log("Removed temp admin", presidency.address, from))

        console.log("### Removing temp masters")
        await _removeMaster(associates, from, from)
        await _removeMaster(respJuridique, from, from)
        await _removeMaster(docJuridiques, from, from)
        await _removeMaster(statuts, from, from)
        await _removeMaster(presidency, from, from)
        await _removeMaster(respRH, from, from)
        await _removeMaster(registreDuPersonnel, from, from)
        await _removeMaster(decisionsAssocies, from, from)
        await _removeMaster(directionGenerale, from, from)
        await _removeMaster(respCompta, from, from)
        await _removeMaster(registreComptable, from, from)
        await _removeMaster(p0ProposerProcedure, from, from)

        console.log("##########################")
        console.log("### Migration finished ###")
        console.log("[")
        console.log("  \""+associates.address+"\",  // Organ: Associes")
        console.log("  \""+respJuridique.address+"\",  // Organ: respJuridique")
        console.log("  \""+docJuridiques.address+"\",  // Organ: docJuridiques")
        console.log("  \""+statuts.address+"\",  // Organ: statuts")
        console.log("  \""+presidency.address+"\",  // Organ: Presidence")
        console.log("  \""+respRH.address+"\",  // Organ: respRH")
        console.log("  \""+registreDuPersonnel.address+"\",  // Organ: registreDuPersonnel")
        console.log("  \""+decisionsAssocies.address+"\",  // Organ: decisionsAssocies")
        console.log("  \""+directionGenerale.address+"\",  // Organ: directionGenerale")
        console.log("  \""+respCompta.address+"\",  // Organ: respCompta")
        console.log("  \""+registreComptable.address+"\",  // Organ: registreComptable")
        console.log("  \""+p0ProposerProcedure.address+"\",  // Organ: p0ProposerProcedure")
        console.log("  \""+p1a.address+"\",  // Procedure: p1a")
        console.log("  \""+p1b.address+"\",  // Procedure: p1b")
        console.log("  \""+p2.address+"\",  // Procedure: p2")
        console.log("  \""+p3.address+"\",  // Procedure: p3")
        console.log("  \""+p4.address+"\",  // Procedure: p4")
        console.log("  \""+p5.address+"\",  // Procedure: p5")
        console.log("]")
        console.log("User roles")
        console.log("    0x6E5329026eB58d6242A2633871a063464B098C7A  // (President)")
    })
}