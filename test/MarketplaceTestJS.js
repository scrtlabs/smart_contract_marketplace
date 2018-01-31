var utils = require("../system_node_tests/utils");
var Marketplace = artifacts.require("./Marketplace.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");

const simple = true;
const complicated = true;
const subscriptions = true;
const mock = true;

contract('Marketplace', function(accounts) {

	const dataSet1 = "Data1";
	const dataSet2 = "Data2";
	const expiredDataSet = "ExpiredData";
	const dataOwner1= accounts[1];
	const price1= 100;
	const price2= 200;
	const price3 = 320;
	const subscriber1 = accounts[0];
	const expiredSubscriber = accounts[0];
 if(simple && true)
  it("Should register Data 2 providers ",function(){
    return Marketplace.deployed().then(instance=>{
      marketPlace = instance;
      return instance.register(dataSet1,price1,dataOwner1,{from:accounts[0]});
    }).then(tx=>{
      return marketPlace.register(dataSet2,price2, dataOwner1,{from:accounts[0]});
    }).then(tx=>{
    	return marketPlace.getAllProviders.call();
    }).then(list=>{
    	assert.equal(utils.toAscii(list[1]),dataSet1,"Data1 registration is not equal");
    	assert.equal(utils.toAscii(list[2]),dataSet2,"Data2 registration is not equal");
    });
  });
if(simple && true)
  it("Should return all providers", function(){
  	return Marketplace.deployed().then(instance=>{
  		marketPlace = instance;
  		return marketPlace.getAllProviders.call();
  	}).then(providers=>{
  		assert.equal(providers.length,3,"Providers length not equal");
  	});
  });
if(simple && complicated && true)
  it("Should subscribe to dataSet1",function(){
  	return Marketplace.deployed().then(instance=>{
  		marketPlace = instance;
  		return EnigmaToken.deployed().then(instance=>{
  			enigma = instance;
  			return enigma.approve(marketPlace.address, price1, {from:subscriber1});
  		}).then(tx=>{
  			return marketPlace.subscribe(dataSet1,{from:subscriber1});
  		}).then(tx=>{
  			return marketPlace.isExpiredSubscription.call(subscriber1,dataSet1);
  		}).then(bool=>{
  			assert.equal(bool,false,"Subscription is expired => not existing");
  			return marketPlace.getMarketplaceTotalBalance.call();
  		}).then(ContractBalance=>{
  			assert.equal(ContractBalance.toNumber(),price1,"Contract balance is not equal");
  		});
  	});
  });
if(simple && true && complicated)
  it("Should get specific provider details",function(){
  	return Marketplace.deployed().then(instance=>{
  		return instance.getDataProviderInfo.call(dataSet1);
  	}).then(provider=>{
  		var owner = provider[0];
  		var price = provider[1].toNumber();
  		var volume = provider[2].toNumber();
  		var subscriptionNum = provider[3].toNumber();
  		var isProvider= provider[4];
  		var isActive= provider[5];
  		var isPunished= provider[6];
  		assert.equal(owner,dataOwner1,"Dataset owners dont match");
  		assert.equal(price,price1,"Dataset prices dont match");
  		assert.equal(volume,price1,"Dataset volume dont match");
  		assert.equal(subscriptionNum,1,"Dataset subscriptions dont match");
  		assert.equal(isProvider,true,"Dataset is not a provider");
  		assert.equal(isActive,true,"Dataset is not active");
  		assert.equal(isPunished,false,"Dataset is punished");
  	})
  });
if(simple && subscriptions && mock && true)
	it("Should create an expired order and get withdraw amount ",function(){
		return Marketplace.deployed().then(instance=>{
			marketPlace = instance; 
			var punished = true;
			return marketPlace.mockPayableProvider(expiredDataSet,price3,dataOwner1,punished,{from:expiredSubscriber});
		}).then(tx=>{
			return marketPlace.getWithdrawAmount.call(expiredDataSet);
		}).then(balance=>{
			assert.equal(price3/2,balance.toNumber(),"withdraw price is not equal");
		});
	});
if(simple && subscriptions && mock && true)
	it("Should check if a subsbscription is expired",function(){
		return Marketplace.deployed().then(insntace=>{
			return insntace.isExpiredSubscription.call(expiredSubscriber,expiredDataSet);
		}).then(bool=>{
			assert.equal(true,bool,"Dataset is not expired");
		})
	});
if(simple && subscriptions && mock && true)
	it("Should get the refund amount of a subscriber ",function(){
		return Marketplace.deployed().then(instance=>{
			return instance.getRefundAmount(expiredSubscriber,expiredDataSet);
		}).then(refundAmount=>{
			assert(price3/2, refundAmount.toNumber(),"Refund amount dont match");
		});
	});
});
