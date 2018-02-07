
var HDWalletProvider = require("truffle-hdwallet-provider");

var DummyMnemonic = "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat";

module.exports = {
    networks: {
    development: {
      host: "127.0.0.1",
      port:9545,// 9545,//8545,//
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(DummyMnemonic, "https://ropsten.infura.io/0oo5uLogrmd5FxaRoiyK")
      },
      network_id: 3,
      gas: 999999999999999,
    } 
  },
  // solc: {
  // optimizer: { 
  //   enabled: true,
  //   runs: 200
  // 	}
  // }
};


