let contract = require('truffle-contract');
let EnigmaABI = require("../build/contracts/EnigmaToken.json");
let MarketPlaceABI = require ("../build/contracts/MarketPlace.json");
// contracts
let EnigmaContract = contract(EnigmaABI);
let MarketPlaceContract = contract(MarketPlaceABI);
// Web3
let Web3 = require('web3');
let provider = new Web3.providers.HttpProvider("http://localhost:8545");
let web3 = new Web3(provider);
EnigmaContract.setProvider(provider);
MarketPlaceContract.setProvider(provider);

function enigmaToken(){
	return EnigmaContract.deployed();
}
function marketPlace(){
	return MarketPlaceContract.deployed();
}

let acc0 = '0x627306090abaB3A6e1400e9345bC60c78a8BEf57';
let acc1 = '0xf17f52151EbEF6C7334FAD080c5704D77216b732';
let acc2 = '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef';

/* simple balance call */
function checkAddrCoinBalance(addr,callback){
	EnigmaContract.deployed().then((instance) => {
	    return instance.balanceOf.call(addr);
	}).then(callback);
}


var approvePayment = function(owner,spender,amount){
	return new Promise((resolve,reject)=>{
		enigmaToken().then(instance=>{
			var tx = instance.approve(spender,amount, {from:owner});
			resolve(tx);
		});
	});
};

// approvePayment(acc0,acc1,150).then(tx=>{
// 	console.log(tx);
// });

EnigmaContract.deployed().then(instance=>{
	instance.approve('0x627306090abaB3A6e1400e9345bC60c78a8BEf57',100);
}).then(tx=>{
	console.log(tx);
});
/************************************************************************/
/******************* TESTS **********************************************/
/************************************************************************/
let addrOwner = '0x627306090abaB3A6e1400e9345bC60c78a8BEf57';
let address = addrOwner;
if(false)
checkAddrCoinBalance(address,(balance) => {
		console.log("The balance: " + balance.valueOf());
});


