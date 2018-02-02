
var utils = require("../system_node_tests/utils");
//var Marketplace = artifacts.require("./Marketplace.sol");
var Marketplace = artifacts.require("./mocks/TestableMock.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");


const simple = true;
const mock = true;
const system_test = true;



contract('Marketplace Mock', function(accounts) {
const emptyAddress ="0x0000000000000000000000000000000000000000000000000000000000000000";
 // provider 1
 const owner1 = accounts[1];
 const data1 = "Data1";
 const price1 = 5000;
 // provider 2
 const owner2 = accounts[1];
 const data2 = "Data2";
 const price2 = 2000;
 // provider 3
 const owner3 = accounts[2];
 const data3 = "Data3";
 const price3 = 10000;
 // provider 4
 const expiredOwner = accounts[3];
 const dataExpired = "Expired";
 const priceExpired = 11000;
 // provider 5
 const expiredAndPunishedOwner = accounts[4];
 const dataExpiredAndPunished = "ExpiredAndPunished";
 const priceExpiredAndPunished= 100000;
 // subscriber1 
 const subscriber1 = accounts[5]; 
 const initialBal1 = priceExpiredAndPunished *3;
 // subscriber2 
 const subscriber2 = accounts[6];
 const initialBal2 = priceExpiredAndPunished *3;
 // subscriber3 
 const subscriberRefund = accounts[7];
 const initialBalRefund = priceExpiredAndPunished *3;
 
 if(simple && true)
  it("Should get the correct Marketplace version",()=>{
    Marketplace.deployed().then(instance=>{
      return insntace.MARKETPLACE_VERSION.call();
    }).then(version=>{
      assert.equal("1",version,"versions dont match");
    });
  });
 if(simple && system_test && true)
  it("Should initiate the testing enviorment",()=>{
    return EnigmaToken.deployed().then(instance=>{
      eng = instance;
      return eng.transfer(subscriber1,initialBal1,{from:accounts[0]});
    }).then(tx=>{
      return eng.transfer(subscriber2,initialBal1,{from:accounts[0]});
    }).then(tx=>{
      return eng.transfer(subscriberRefund,initialBal1,{from:accounts[0]});
    }).then(tx=>{
      return eng.balanceOf.call(subscriber1);
    }).then(bal=>{
      bal1 = bal.toNumber();
      return eng.balanceOf.call(subscriber2);
    }).then(bal=>{
      bal2 = bal.toNumber();
      return eng.balanceOf.call(subscriberRefund);
    }).then(bal=>{
      bal3 = bal.toNumber();
      assert.equal(initialBal1,bal1, "balances not equal");
      assert.equal(initialBal1,bal2, "balances not equal");
      assert.equal(initialBal1,bal3, "balances not equal");
    });
  });
  if(simple && system_test && true)
    it("Should register 3 data providers",()=>{
      return Marketplace.deployed().then(instance=>{
        mp = instance;
        return mp.register(data1, price1, owner1,{from:owner1});
      }).then(tx=>{
        return mp.register(data2, price2, owner2,{from:owner2});
      }).then(tx=>{
        return mp.register(data3, price3, owner3,{from:owner3});
      }).then(tx=>{
        return mp.getAllProviders.call();
      }).then(providers=>{
        shouldExist = [data1,data2,data3];
        providers.forEach(p=>{
          if(p != emptyAddress){
            var contains = shouldExist.indexOf(utils.toAscii(p))>-1;
            assert(contains,true, "provider is not registerd");
          }
        });
      });
    });

 if(simple && system_test && true)
  it("Register (mock) expired data set, refund and withdraw",()=>{
    return EnigmaToken.deployed().then(instance=>{
      relativePunish =2;
      enigma = instance;
      return Marketplace.deployed().then(instance=>{
        mp = instance;
        return enigma.approve(mp.address,priceExpiredAndPunished,{from:subscriberRefund});
      }).then(tx=>{
        return enigma.allowance(subscriberRefund,mp.address);
      }).then(allowed=>{
        assert.equal(allowed.toNumber(),priceExpiredAndPunished,"allowance not equal");
        withTx = true;
        return mp.mockPayableProvider(
          dataExpiredAndPunished,
          priceExpiredAndPunished,
          expiredAndPunishedOwner,
          true,
          relativePunish,
          withTx,
          {from:subscriberRefund});
      }).then(tx=>{
        return mp.getWithdrawAmount.call(dataExpiredAndPunished);
      }).then(withdraw=>{
        assert.equal(withdraw.toNumber(),priceExpiredAndPunished/relativePunish, "withdraw and price not equal");
        return mp.getRefundAmount.call(subscriberRefund,dataExpiredAndPunished);
      }).then(refund=>{
        assert.equal(refund.toNumber(),priceExpiredAndPunished/relativePunish,"refund amount not equal");
        return mp.withdrawProvider(dataExpiredAndPunished, {from:expiredAndPunishedOwner});
      }).then(tx=>{
        return mp.getWithdrawAmount.call(dataExpiredAndPunished);
      }).then(withdraw=>{
        assert.equal(withdraw.toNumber(),0, "withdraw not 0");
        return mp.refundSubscriber(dataExpiredAndPunished,{from:subscriberRefund});
      }).then(tx=>{
        return mp.getRefundAmount.call(subscriberRefund,dataExpiredAndPunished);
      }).then(refund=>{
        assert.equal(refund.toNumber(),0,"refund not 0");
        return enigma.balanceOf.call(subscriberRefund);
      }).then(subscriberBalance=>{
        assert.equal(subscriberBalance.toNumber(),initialBalRefund - priceExpiredAndPunished/relativePunish,"ENG subscriber wrong balance");
        return enigma.balanceOf.call(expiredAndPunishedOwner);
      }).then(providerBalance=>{
        assert.equal(providerBalance.toNumber(),priceExpiredAndPunished/relativePunish,"ENG provider wrong balanc");
      });
    });
  });

  if(simple && system_test && true)
    it("Should register 2 subscribers to 3 data setes",()=>{
      return EnigmaToken.deployed().then(instance=>{
        enigma = instance;
        return Marketplace.deployed().then(instance=>{
          mp = instance;
          return enigma.approve(mp.address,price1,{from:subscriber1});
        }).then(tx=>{
          return enigma.increaseApproval(mp.address,price2,{from:subscriber1});
        }).then(tx=>{
          return enigma.approve(mp.address,price3,{from:subscriber2});
        }).then(tx=>{
          return enigma.allowance(subscriber1,mp.address);
        }).then(allowed=>{
          assert.equal(allowed.toNumber(),price1+price2,"allowed is not equal to price");
          return enigma.allowance(subscriber2,mp.address);
        }).then(allowed=>{
          assert.equal(allowed.toNumber(),price3,"allowed is not equal to price");
          return mp.subscribe(data1,{from:subscriber1});
        }).then(tx=>{
          return mp.subscribe(data2,{from:subscriber1});
        }).then(tx=>{
          return mp.subscribe(data3,{from:subscriber2});
        }).then(tx=>{
          return mp.checkAddressSubscription.call(subscriber1,data1);
        }).then(subscription=>{
          var s1 = parseSubscription(subscription);
          var equal = isEqualSubscriptions(s1,{susbcriber:subscriber1,dataName:data1,price:price1,isUnExpired:true,isPaid:false,isPunishedProvider:false,isOrder:true});
          assert.equal(equal,true,"Subscription1 is not equal");
          return mp.checkAddressSubscription.call(subscriber1,data2);
        }).then(subscription=>{
          var s2 = parseSubscription(subscription);
          var equal = isEqualSubscriptions(s2,{susbcriber:subscriber1,dataName:data2,price:price2,isUnExpired:true,isPaid:false,isPunishedProvider:false,isOrder:true});
          assert.equal(equal,true,"Subscription2 is not equal");
          return mp.checkAddressSubscription.call(subscriber2,data3);
        }).then(subscription=>{
          var s3 = parseSubscription(subscription);
          var equal = isEqualSubscriptions(s3,{susbcriber:subscriber2,dataName:data3,price:price3,isUnExpired:true,isPaid:false,isPunishedProvider:false,isOrder:true});
          assert.equal(equal,true,"Subscription3 is not equal");
        });
      });
    });

  if(simple && system_test && true)
    it("Should try subscribing to an expired and punished data set and fail",async function(){
      let marketPlace = await Marketplace.deployed();
      try{
        await marketPlace.subscribe(expiredAndPunishedOwner,{from:subscriber3});
      } catch(e){
        return true;
      }
    });
  //
});

function parseSubscription(info){
  var normal = {};
  normal.susbcriber = info[0];
  normal.dataName = utils.toAscii(info[1]);
  normal.price = info[2].toNumber();
  normal.startTime = info[3].toNumber();
  normal.endTime = info[4].toNumber();
  normal.isUnExpired = info[5];
  normal.isPaid = info[6];
  normal.isPunishedProvider = info[7];
  normal.isOrder = info[8];
  return normal;
}
function isEqualSubscriptions(sub1,sub2){
  return sub1.subscriber == sub2.subscriber &&
  sub1.dataName ==sub2.dataName &&
  sub1.price ==sub2.price &&
  sub1.isUnExpired==sub2.isUnExpired &&
  sub1.isPaid==sub2.isPaid &&
  sub1.isPunishedProvider==sub2.isPunishedProvider &&
  sub1.isOrder ==sub2.isOrder;
}
function printSubscriptionInfo(info){
  var s = parseSubscription(info);
  console.log("susbcriber : " +s.susbcriber );
  console.log("dataName : " +s.dataName );
  console.log("price : " + s.price);
  console.log("startTime : " + s.startTime);
  console.log("endTime : " +s.endTime );
  console.log("isUnExpired : " + s.isUnExpired);
  console.log("isPaid : " + s.isPaid);
  console.log("isPunishedProvider : " + s.isPunishedProvider);
  console.log("isOrder : " + s.isOrder);
}
function printProviderInfo(info){
        var owner = info[0];
        var price = info[1].toNumber();
        var volume = info[2].toNumber();
        var subscriptionsNum = info[3].toNumber();
        var isProvider =info[4];
        var isActive = info[5];
        var isPunished = info[6];
        console.log("owner: " + owner);
        console.log("price : " + price);
        console.log("volume : " + volume);
        console.log("subscsnum : " + subscriptionsNum);
        console.log("isProvider: " +isProvider );
        console.log("isActive : " + isActive);
        console.log("isPunished : " +isPunished );
}


