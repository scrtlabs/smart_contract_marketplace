var utils = require("../system_node_tests/utils");
var Marketplace = artifacts.require("./Marketplace.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");



contract('Marketplace', function(accounts) {

	const dataSet1 = "Data1";
	const dataSet2 = "Data2";
	const dataOwner1= accounts[1];
	const price1= 100;
	const price2= 200;
	const subscriber1 = accounts[0];

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
  it("Should return all providers", function(){
  	return Marketplace.deployed().then(instance=>{
  		marketPlace = instance;
  		return marketPlace.getAllProviders.call();
  	}).then(providers=>{
  		assert.equal(providers.length,3,"Providers length not equal");
  	});
  });
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
  		});
  	});
  });
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
});
