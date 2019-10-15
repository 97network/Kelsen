var Organ = artifacts.require("Organ");

async function _removeMaster(organ, address, from) {
    return organ.remMaster(address, { from })
    .then(_ => console.log("Removed master", organ.address, address))
}

module.exports = async callback => {
  var accounts = await web3.eth.getAccounts()
  console.log(accounts)

  // Organs
  const
    associates = await Organ.at("0x14371144A31188F9c69c4E9593c95edf2a121f56"),
    respJuridique = await Organ.at("0xF487Dd76EEE3c2162Bbf5FAd26f7F83077656E04")
    docJuridiques = await Organ.at("0xF620e8deF628Ec39f3d2B1f43c7287CD1E15454a"),
    statuts = await Organ.at("0x3AAE2ABb09428DaA7dBbB5581cF04D867940f250"),
    presidency = await Organ.at("0x8Ce3228Cc56945E079fFC3ef9bdB4940cEb4961D"),
    respRH = await Organ.at("0x5FE32a1fd0030b9B97Bf76e0E13352b834a342e5"),
    registreDuPersonnel = await Organ.at("0x5b979ba1ED5a6F17CF5Ea887d73c2eA88d5c52A1"),
    decisionsAssocies = await Organ.at("0xe04705cc1F87cF84E6EF8aC6A7557E0f7045e131"),
    directionGenerale = await Organ.at("0xd4812a4cd936D49d08374455401205a19df6dE7C"),
    respCompta = await Organ.at("0xaFcb3D82b0d12d31a0A2851230c77C65ae4b8425"),
    registreComptable = await Organ.at("0x7121858A1809b2B0C63Ea0289CC409BCEEe17d2B"),
    p0ProposerProcedure = await Organ.at("0xbA095bE3c46aF0c760ff8792228cc42C089dB328"),
    p1a = { address: "0x1779Cf2772cA4aD69d6ba9ac44580bf8DC44FaeF" },
    p1b = { address: "0xFC1611B47058425FE7f064A89CD0E95D1039279f" },
    p2 = { address: "0xD40A17635d20Fd76dCA5fDD1c5007Ec9FFf1aa54" },
    p3 = { address: "0x038c8425e4244C6901E82F14CE99e6D25f5e7601" },
    p4 = { address: "0xf8dCC3Bb733f4253D3C93bB50618C1694c68984a" },
    p5 = { address: "0xce515a6a2A6bf51f8fbf89eD8182dF4628eEBA74" },
    from = accounts[0],
    acc1 = "0xc3a7897616Ae683089C737076e2751ADC9ecE481"

  // Migration
  await associates.addNorm(acc1, "Account 1", "0x", 0, 0, { from })
  .then(_ => console.log("Added entry", associates.address, acc1))

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
  
  callback()
}