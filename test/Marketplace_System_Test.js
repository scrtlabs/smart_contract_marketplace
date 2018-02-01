var utils = require("../system_node_tests/utils");
//var Marketplace = artifacts.require("./Marketplace.sol");
var Marketplace = artifacts.require("./mocks/TestableMock.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");


const simple = true;
const mock = true;
const system_test = true;

contract('Marketplace Mock', function(accounts) {
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

    toDistribute = [{addr:subscriber1,initial: initialBal1},
    {addr:subscriber2,initial: initialBal2},
    {addr:subscriberRefund,initial: initialBalRefund}];

    return EnigmaToken.deployed().then(instance=>{
      distribute(instance,accounts[0],toDistribute).then(success=>{
        assert.equal(success,true,"Initiation failed");
      })
    });
  });
 if(simple && system_test && true)
  it("Should register 3 normal dataSets",()=>{
    return Marketplace.deployed().then(instance=>{
      
      toRegister = [{addr:owner1,price:price1,name:data1},
      {addr:owner2,price:price2,name:data2},
      {addr:owner3,price:price3,name:data3}];

      registerAll(instance,toRegister).then(success=>{
        assert.equal(success,true,"Registration failed");
      });
    });
  });
 if(simple && system_test && true)
  it("Register (mock) expired data set",()=>{
    
  });
});



function distribute(token,distributer,accounts){
  var counter = 0;
  var len = accounts.length-1;
  return new Promise((mResolve,reject)=>{
    accounts.forEach(account=>{
    var b = account.initial;
    var a = account.addr;
    new Promise((resolve,reject)=>{
      tx = token.transfer(a,b,{from:distributer});
      resolve(tx);
    }).then(tx=>{
      return token.balanceOf.call(a);
    }).then(balance=>{
      assert.equal(b,balance.toNumber(),"balances don't match");
      counter++;
    }).then(()=>{
      if(counter == len)
        mResolve(true);
    })
  })
  });
}

function registerAll(marketPlace,providers){
  var counter = 0;
  var len = providers.length-1;
  return new Promise((mResolve,mReject)=>{
    providers.forEach(provider=>{
      var a = provider.addr;
      var p = provider.price;
      var n = provider.name;
      new Promise((res,rej)=>{
        tx = marketPlace.register(n,p,a,{from:a});
        res(tx);
      }).then(tx=>{
          return marketPlace.getDataProviderInfo.call(n);
      }).then(info=>{
        //printProviderInfo(info);
        var owner = info[0];
        var price = info[1].toNumber();
        var volume = info[2].toNumber();
        var subscriptionsNum = info[3].toNumber();
        var isProvider =info[4];
        var isActive = info[5];
        var isPunished = info[6];
        assert.equal(owner,a,"address incorect");
        assert.equal(price,p,"price incorect");
        assert.equal(volume,0,"volume incorect");
        assert.equal(subscriptionsNum,0,"subscriptions incorect");
        assert.equal(isProvider,true,"isProvider incorect");
        assert.equal(isActive,true,"isActive incorect");
        assert.equal(isPunished,false,"isPunished incorect");
        counter++;
        return true;
      }).then(one_succ=>{
        if(counter == len)
          mResolve(true);
      });
    });
  });
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