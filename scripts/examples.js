

const utils = require("./utils");
const config = require("./config_web3");
const web3 = config.web3;
const EnigmaContract = config.EnigmaContract;
const MarketPlaceContract = config.MarketPlaceContract;

let gas = 740000;
let theOwner = web3.eth.accounts[0];
// provider 
var _provider = {};
_provider.address = web3.eth.accounts[1];
_provider.dataName = "Dat3asas1";
_provider.price = 1500;
//subscriber 
var _subscriber = {};
_subscriber.address = web3.eth.accounts[2];

async function transfer(from,to,amount){
	let enigma = await EnigmaContract.deployed();
	let tx = await enigma.transfer(to,amount,{from:from});
	return tx;
}

async function register(provider){
	let marketPlace = await MarketPlaceContract.deployed();	
	let enigma = await EnigmaContract.deployed();
	let version = await marketPlace.MARKETPLACE_VERSION.call();
	// register probider 
	let reg_tx = await marketPlace.register(provider.dataName,provider.price,provider.address,{from:provider.address,gas:gas});
	// validate
	let providerInfo = await marketPlace.getDataProviderInfo.call(provider.dataName);
	console.log("registred! ");
	return providerInfo;
}

async function subscribe(provider,subscriber){
	let marketPlace = await MarketPlaceContract.deployed();	
	let enigma = await EnigmaContract.deployed();
	// #1 approve the marketPlace as a spender in EnigmaToken 
	let tx_app = await enigma.approve(marketPlace.address,provider.price,{from:subscriber.address,gas:gas});
	// validate allowed amount 
	let allowed = await enigma.allowance.call(subscriber.address,marketPlace.address); 
	console.log(allowed.toNumber());
	// #2 subscribe to marketPlace
	let tx_sub = await marketPlace.subscribe(provider.dataName,{from:subscriber.address,gas:gas});
	//validate subscription // subscriber,dataSourceName,price,startTime,endTime,isUnExpired,isPaid,isPunishedProvider,isOrder
	let subInfo = await marketPlace.checkAddressSubscription.call(subscriber.address,provider.dataName);
	
}

// registration + subscription

transfer(theOwner,_subscriber.address,_provider.price).then(tx=>{
	register(_provider).then(info=>{
		subscribe(_provider,_subscriber).then(async function(){
			getAllProviders().then(providers=>{
				getProvidersRecover().then(providers=>{
					getSubscriptionsOfProviderRecover(providers[0]);
				});
			});
		});
	});
});

// get all providers + their info (provoder[0] = 0x0 just an indicator)
async function getAllProviders(){
	let providerInfo = [];
	let marketPlace = await MarketPlaceContract.deployed();	
	let providers = await marketPlace.getAllProviders.call();
	for(var i in providers){
		let info = await marketPlace.getDataProviderInfo.call(web3.toAscii(providers[i]));
		providerInfo.push({name: providers[i], info: info});
	}
	return providerInfo;
}

async function getProvidersRecover(){
	let providers = [];
	let marketPlace = await MarketPlaceContract.deployed();	
	let size = await marketPlace.getProviderNamesSize.call();
	for(let i=0;i<size.toNumber();++i){
		let providerName = await marketPlace.getNameAt.call(i);
		providers.push(providerName);
		let provider = await marketPlace.getDataProviderInfo.call(web3.toAscii(providerName));
	}
	return providers;
}
async function getSubscriptionsOfProviderRecover(providerName){
	let subscriptions = [];
	let marketPlace = await MarketPlaceContract.deployed();	
	let size = await marketPlace.getSubscriptionsSize.call(providerName);
	for(var i=0;i<size.toNumber();i++){
		let subscription = await marketPlace.checkSubscriptionAt.call(providerName,i);
		subscription.push(subscription);
	}
	return subscriptions;
}

getAllProviders().then(providers=>{
	// get all providers.
});




