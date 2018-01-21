
/************************************************************************/
/******************* Configuration **************************************/
/************************************************************************/
const config = require("./config_web3");
enigma = config.enigma;
marketPlace = config.marketPlace;
web3= config.web3;

/************************************************************************/
/******************* Registration test **********************************/
/************************************************************************/

let gas = 999999999;

// Some data curator wants to register his data set. 
// 1) Register Dataset A => success
// 2) then try registering Dataset A again => throw 

/* set a listener = > registration event will happen in the future */
// 'Registered' => event Registered(address indexed dataOwner, bytes32 indexed dataSourceName, uint price, bool success);
let eventRegistered;
function testRegisteredEventListener(){
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
}

/* registration process*/ //{from,name,price,owner}
function testRegistration(params){
	p=params;
	return marketPlace().then((instance)=>{
	contract = instance;
	return contract.register(p.name,p.price,p.owner,{from:p.from,gas:gas});
	});
}
/* same name and error handling registration */
function testDoubleRegistrationError(params){
	p=params;
	marketPlace().then((instance)=>{
	contract = instance;
	return contract.register(p.name,p.price,p.owner,{from:p.from,gas:gas});
	}).then((txRecipt)=>{
		// txRecipt => recipt for the future transactions.
		return contract.register(p.name,p.price,p.owner,{from:p.from,gas:gas});
	}).catch((err)=>{
		// handle Contracts throw. // CONTRACT 
		console.log("Solidity throw",err);
	});
}


/* test activation */

//testRegisteredEventListener();
//testRegistration({from: web3.eth.coinbase, name: "DataSet30" , price:100 , owner:web3.eth.coinbase});
//testDoubleRegistration();


/************************************************************************/
/******************* Subscription test **********************************/
/************************************************************************/

let dataSourceName = "BittrexCandlesData";


// Some user wants to subscribe to a data provider
// 1) approve() in the token contract.
// 2) subscribe() in the marketplace contract.

// the data provider - registerd
let dataProvider = web3.eth.accounts[1];
// the data consumer
let subscriber = web3.eth.accounts[0];
let price = 100;

/* EVENT HANDLING */

// enigma token event:
// this means a client approved the marketplace contract to pay for him.
//event Approval(address indexed owner, address indexed spender, uint256 value);
// marketplace event:
// solidity event for when subscriber pays (happens BEFORE actually changing the data in the contract)
//event SubscriptionPaid(address indexed from, address indexed to, uint256 value);
// solidity event for when the contract updated subscription data AND customer paid
//event Subscribed(address indexed subscriber,bytes32 indexed dataSourceName, address indexed dataOwner, uint price, bool success);
let eventApproval;
let eventSubscribed;

marketPlace().then(instance=>{
	eventSubscribed = instance.Subscribed({dataSourceName:dataSourceName});
	eventSubscribed.watch((err,eventResult)=>{
		// event happend. => user subscribed.
		// check addresss subscription details.
		testCheckAddressSubscription();
		//eventSubscribed.stopWatching();
	});
});
enigma().then(instance=>{
	eventApproval = instance.Approval({owner:subscriber});//({spender:dataProvider});
	eventApproval.watch((err,eventResult)=>{
	// contract is approved -> lets subscribe
	testSubscribe();
	eventApproval.stopWatching();
	});
});


function testApprovalENG(){
	marketPlace().
	then(instance=>{mp = instance;return enigma();}).
		then((instance)=>{ eng = instance; return eng.approve(mp.address,price,{from:subscriber,gas:gas})}).
			then(txRecipt=>{});
}

function testSubscribe(){
	marketPlace().
		then(instance=>{mp = instance; return mp.subscribe(dataSourceName,{from:subscriber,gas:gas})}).
			then(tx=>{})
}

function testCheckAddressSubscription(){
	marketPlace().
	 then(instance=>{ return instance.checkAddressSubscription.call(subscriber,dataSourceName)}).
	 	then(subscriptionInfo=>{
	 		var subscriberAddr = subscriptionInfo[0];
	 		var name = subscriptionInfo[1];
	 		var price = subscriptionInfo[2].toNumber();
	 		var startTime = subscriptionInfo[3].toNumber(); //unix timestamp
	 		var endTime = subscriptionInfo[4].toNumber();
	 		var isExpired = subscriptionInfo[5];
	 	});
}
/* test activation */

/*
testRegistration({from: dataProvider, name: dataSourceName , price:price , owner:dataProvider}).then(()=>{
	testApprovalENG();	
});
*/


