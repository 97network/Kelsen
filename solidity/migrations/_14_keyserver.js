var deployOrgan = artifacts.require('deployOrgan')
var deploySimpleNormNominationProcedure = artifacts.require("deploySimpleNormNominationProcedure")

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

module.exports = function(deployer, network, accounts) {
    const from = accounts[0]
    deployer.then(async _ => {
        console.log("### Deploying Kelsen contracts")
        const keyserver = await _deployOrgan("GPG Keyserver", from)
        const registration = await _deployProcedurePromise(
            deploySimpleNormNominationProcedure.new("0x0000000000000000000000000000000000000000", "GPG Key Registration", { from }),
            "GPG Key Registration"
        )
    
        console.log("### Setting organ parameters.")
        await keyserver.addAdmin(registration.address, true, false, false, false, "GPG Key Registration", { from })
        .then(_ => console.log("Added Admin", keyserver.address, registration.address))
    
        console.log("##########################")
        console.log("### Migration finished ###")
        console.log("[")
        console.log("  \""+keyserver.address+"\",  // Organ: GPG Keyserver")
        console.log("  \""+registration.address+"\",  // Procedure: GPG Key Registration")
        console.log("]")
    })
}