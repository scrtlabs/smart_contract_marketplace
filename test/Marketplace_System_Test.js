
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
 const price1 = 12000;
 // provider 2
 const owner2 = accounts[1];
 const data2 = "Data2";
 const price2 = 25000;
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
   
  
});



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


