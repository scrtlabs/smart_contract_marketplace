# smart_contract_marketplace

A Smart contract that interacts with the Enigma Token.

The purpose is to store data for Enigma's marketplace.


## Getting Started


### Prerequisites

- Ganache test network (optional)
- Unix supporting OS.
- solc compiler 
- nodeJS
- Truffle

### Installing

NodeJS

```
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get -y install curl git vim build-essential
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g express
```

Truffle

```
sudo npm install -g truffle
```


## Running the tests

To run Truffle tests


```
truffle test
```
To run system test 


```
node system_node_tests/registration_subscription.js
```


## Deployment

### Compiling

```
truffle compile
```
### Migration

Use with --reset flag for restarting migrations.

```
truffle migrate 
```
### API

```node

let EnigmaABI = require("../build/contracts/EnigmaToken.json");
let MarketPlaceABI = require ("../build/contracts/MarketPlace.json");
let contract = require('truffle-contract');
// contracts
let EnigmaContract = contract(EnigmaABI);
let MarketPlaceContract = contract(MarketPlaceABI);
// Web3
let Web3 = require('web3');
let provider = new Web3.providers.HttpProvider("http://localhost:8545");
let web3 = new Web3(provider);
EnigmaContract.setProvider(provider);
MarketPlaceContract.setProvider(provider);

module.exports.enigma = function(){return EnigmaContract.deployed();}
module.exports.marketPlace = function(){return MarketPlaceContract.deployed();}
module.exports.web3= web3;

```

## Built With

* [Ganache](http://truffleframework.com/ganache/) -Test network
* [Truffle](http://truffleframework.com/) - Testing and deployment.

