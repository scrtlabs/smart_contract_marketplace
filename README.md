# Enigma Data Marketplace Smart Contract

The documentation for the Enigma Data Marketplace Smart Contract is available at [https://enigmampc.github.io/marketplace/smart-contract.html].

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

The tests has to be deployed with an ERC20 Token, the original implementation is in /contracts/token.
Due to that, the tokens are deployed as well in the migration file.


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
### Examples:

Web3 connection:


```node

let EnigmaABI = require("../build/contracts/EnigmaToken.json");
let MarketPlaceABI = require ("../build/contracts/Marketplace.json");
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

To register a data source.

```node
	var price = 100;
	var owner = web3.eth.accounts[0];
	var deployer = web3.eth.accounts[0];

	marketPlace().then((instance)=>{
		contract = instance;
		return contract.register('data name',price,owner,{from:deployer,gas:999999});
	});
```

Listen to Blockchain events:

```node
  marketPlace().then(instance=>{
	eventRegistered = instance.Registered(); // => add filters Registered({from:, price:})
	eventRegistered.watch((err,eventResult)=>{
		// handle events...
		// bytes to ascii
		var name = web3.toAscii(eventResult.args.dataSourceName);
		// stop watching for events.
		eventRegistered.stopWatching(); 
	});
  });
```
Approve the ERC20 token contract as a spender on behalf of X:
Trigers Approval() event.

```node
	var allowance = 100;
	var subscriber = web3.eth.accounts[0];
	var gas = 99999;
	marketPlace().
	then(instance=>{mp = instance;return enigma();}).
		then((instance)=>{ eng = instance; return eng.approve(mp.address,allowance,{from:subscriber,gas:gas})}).
			then(txRecipt=>{ // tx recipt ...});
```

allowance() and transferFrom() functions are encapsulated inside Marketplace, an internal safeTransfer() function 

will run the payment process and trigger a SubscriptionPaid() event. 


```node
	function safeTransfer(address _from, address _to, uint256 _amount) internal returns (bool){
		require(address(_from) != 0 && address(_to)!=0);
		require(mToken.allowance(_from,address(this)) >= _amount);
		require(mToken.transferFrom(_from,_to,_amount));
		SubscriptionPaid(_from, _to, _amount);
		return true;
	}
```

## Built With

* [Ganache](http://truffleframework.com/ganache/) -Test network
* [Truffle](http://truffleframework.com/) - Testing and deployment.

