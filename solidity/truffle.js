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
      port: 8546,
      network_id: "*",
      gasPrice: 11000000000
    },
    rinkeby: {
      host: "localhost",
      port: 8545,
      network_id: 4,
	gasPrice: 11000000000
    }
  }
}
