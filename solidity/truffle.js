var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic2 = "document isolate veteran banner capable grass pulse royal field hero trouble random"
var infura_apikey = "2cce1f049fc04dac8240247dfbcbeff3"

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "1337",
      gasPrice: 11000000000
    },
    ganache: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      gasPrice: 11000000000
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: 4,
	   gasPrice: 11000000000
    },
    rinkebyinfura: {
      provider: new HDWalletProvider(mnemonic2, "https://rinkeby.infura.io/v3/"+infura_apikey),
      network_id: 4,
      gasPrice: 2000000000,
      skipDryRun: true
    }
  },
  compilers: {
    solc: 
      {
      version: "0.4.11"
      }
    }


}
