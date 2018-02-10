var utils = require("../scripts/utils");
//var Marketplace = artifacts.require("./Marketplace.sol");
var Marketplace = artifacts.require("./RecoverableMarketplace.sol");
var Marketplace = artifacts.require("./mocks/TestableMock.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");


const simple = true;
const complicated = true;
const subscriptions = true;
const mock = false;
contract('Marketplace', function(accounts) {

	const dataSet1 = "Data1";
	const dataSet2 = "Data2";
	const expiredDataSet = "ExpiredData";
	const dataOwner1= accounts[1];
	const price1= 1000;
	const price2= 200;
	const price3 = 320;
	const subscriber1 = accounts[0];
	const expiredSubscriber = accounts[0];
 if(simple && true)
 	it("Should get the contract version",function(){
 		return Marketplace.deployed().then(insntace=>{
 			return insntace.MARKETPLACE_VERSION.call();
 		}).then(v=>{
 			var version = "1";
 			assert.equal(version,v,"versions dont match");
 		});
 	});
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
if(simple && complicated && true)
  it("Should check Address Subscription info",function(){
  	return Marketplace.deployed().then(instance=>{
  		return instance.checkAddressSubscription.call(subscriber1,dataSet1);
  	}).then(info=>{
  		assert.equal(subscriber1,info[0]," wrong subscriber")
  		assert.equal(dataSet1,utils.toAscii(info[1]),"wrong data set name");
  		assert.equal(price1,info[2].toNumber(),"wrong price");
  		assert.equal(true,info[5],"wrong isUnExpired");
  		assert.equal(false,info[6],"wrong isPaids");
  		assert.equal(false,info[7],"wrong isPunished");
  		assert.equal(true,info[8],"wrong isOrder");
  	})
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
      var withTx = false;
      var relativePunish =2;
			return marketPlace.mockPayableProvider(expiredDataSet,price3,dataOwner1,punished,relativePunish,withTx,{from:expiredSubscriber});
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
if(simple && subscriptions && mock && true)
	it("Should withdraw providers tokens",function(){
		return Marketplace.deployed().then(instance=>{
			marketPlace = instance;
			return instance.withdrawProvider(expiredDataSet,{from:dataOwner1});
		}).then(tx=>{
			return EnigmaToken.deployed().then(instance=>{
				enigma = instance;
				return enigma.balanceOf(dataOwner1);
			}).then(balance=>{
				assert.equal(price3/2,balance.toNumber(),"Balances are not equal after withdraw");
				return marketPlace.getWithdrawAmount(expiredDataSet);
			}).then(refund=>{
				var left = 0;
				assert.equal(refund.toNumber(),left,"The withdraw calculation is incorect.");
			});
		});
	});
 if(simple && subscriptions && mock && true)
 	it("Should refund a subscriber",function(){
 		return Marketplace.deployed().then(instance=>{
 			marketPlace = instance;
 			return marketPlace.refundSubscriber(expiredDataSet,{from:expiredSubscriber});
 		}).then(tx=>{
 			return marketPlace.getRefundAmount.call(expiredSubscriber,expiredDataSet);
 		}).then(refund=>{
 			assert.equal(refund.toNumber(),0,"Refund amount is not equal");
 			return EnigmaToken.deployed().then(instance=>{
 				return instance.balanceOf.call(expiredSubscriber);
 			}).then(balance=>{
 				var bal = 14999999999999160;
 				assert.equal(balance.toNumber(),bal,"Balance is not equal");
 			});
 		});
 	});
});
