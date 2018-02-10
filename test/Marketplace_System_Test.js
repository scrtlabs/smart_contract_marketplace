
var utils = require("../scripts/utils");
//var Marketplace = artifacts.require("./Marketplace.sol");
//var Marketplace = artifacts.require("./RecoverableMarketplace.sol");
var Marketplace = artifacts.require("./mocks/TestableMock.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");


const simple = true;
const mock = true;
const system_test = true;
const recoverable = true;

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
 // provider recovery 
 const recoverOwner = accounts[8];
 const dataRecoverName = "DataRecover";
 const priceRecover = 2000;
 // provider mock expired 
 const expiredRecoverOwner = accounts[8];
 const dataExpiredRecover = "ExpiredRecover";
 const priceExpiredRecoverd = 1000;
 // subscriber1 
 const subscriber1 = accounts[5]; 
 const initialBal1 = priceExpiredAndPunished *3;
 // subscriber2 
 const subscriber2 = accounts[6];
 const initialBal2 = priceExpiredAndPunished *3;
 // subscriber3 
 const subscriberRefund = accounts[7];
 const initialBalRefund = priceExpiredAndPunished *3;
 // subscriber recover 
 const subscriberRecover = accounts[9];
 const initialRecoverBal = priceExpiredAndPunished *3;
 
 if(simple && true)
  it("Should get the correct Marketplace version",()=>{
    Marketplace.deployed().then(instance=>{
      return insntace.MARKETPLACE_VERSION.call();
    }).then(version=>{
      assert.equal("1",version,"versions dont match");
    });
  });

 if(simple && system_test && true)
  it("Should initiate the testing enviorment",async function(){
    let marketPlace = await Marketplace.deployed();
    let enigma = await EnigmaToken.deployed();
    // transfer tokens 
    await enigma.transfer(subscriber1,initialBal1,{from:accounts[0]});
    await enigma.transfer(subscriber2,initialBal1,{from:accounts[0]});
    await enigma.transfer(subscriberRefund,initialBal1,{from:accounts[0]});
    await enigma.transfer(subscriberRecover,initialRecoverBal,{from:accounts[0]});
    // validate balance 
    let bal1 = await enigma.balanceOf.call(subscriber1);
    let bal2 = await enigma.balanceOf.call(subscriber2);
    let bal3 = await enigma.balanceOf.call(subscriberRefund);
    let bal4 = await enigma.balanceOf.call(subscriberRecover);
    assert.equal(initialBal1,bal1.toNumber(), "balances not equal");
    assert.equal(initialBal1,bal2.toNumber(), "balances not equal");
    assert.equal(initialBal1,bal3.toNumber(), "balances not equal");
    assert.equal(initialBal1,bal4.toNumber(), "balances not equal");
  });
  if(simple && system_test && true)
    it("Should register empty name and throw",async function(){
      let marketPlace = await Marketplace.deployed();
      try{
        await marketPlace.register("", price1, owner1,{from:owner1});
        assert.equal(false,true,"Empty name registred");
      }catch(e){
        return true;
      }
    });
  if(simple && system_test && true)
    it("Should register 3 data providers",async function(){
      let marketPlace = await Marketplace.deployed();
      // register 
      await marketPlace.register(data1, price1, owner1,{from:owner1});
      await marketPlace.register(data2, price2, owner2,{from:owner2});
      await marketPlace.register(data3, price3, owner3,{from:owner3});
      // validate
      let providers = await marketPlace.getAllProviders.call();
      let shouldExist = [data1,data2,data3];
      providers.forEach(p=>{
          if(p != emptyAddress){
            var contains = shouldExist.indexOf(utils.toAscii(p))>-1;
            assert(contains,true, "provider is not registerd");
          }
      });
    });

 if(simple && mock && system_test  && true)
  it("Register (mock) expired data set, refund and withdraw",async function(){
    let withTx = true; // mock function meaninig: do actual token transfer on subscription
    let relativePunish = 2; // meaning => provider got punished half way through the subscription
    let enigma = await EnigmaToken.deployed();
    let marketPlace = await Marketplace.deployed();
    // approval ENG with Marketplace protocol
    await enigma.approve(marketPlace.address,priceExpiredAndPunished,{from:subscriberRefund});
    let allowed = await enigma.allowance(subscriberRefund,marketPlace.address);
    assert.equal(allowed.toNumber(),priceExpiredAndPunished,"allowance not equal");
    // mock => register expired and punished subscription + addsubscriber 
    await marketPlace.mockPayableProvider(
          dataExpiredAndPunished,
          priceExpiredAndPunished,
          expiredAndPunishedOwner,
          true,
          relativePunish,
          withTx,
          {from:subscriberRefund});
    // initial available refund/withdraw 
    let withdraw = await marketPlace.getWithdrawAmount.call(dataExpiredAndPunished);
    assert.equal(withdraw.toNumber(),priceExpiredAndPunished/relativePunish, "withdraw and price not equal");
    let refund = await marketPlace.getRefundAmount.call(subscriberRefund,dataExpiredAndPunished);
    assert.equal(refund.toNumber(),priceExpiredAndPunished/relativePunish,"refund amount not equal");
    // tx: withdraw refund/withdraw
    await marketPlace.withdrawProvider(dataExpiredAndPunished, {from:expiredAndPunishedOwner});
    withdraw = await marketPlace.getWithdrawAmount.call(dataExpiredAndPunished);
    assert.equal(withdraw.toNumber(),0, "withdraw not 0");
    await marketPlace.refundSubscriber(dataExpiredAndPunished,{from:subscriberRefund});
    refund = await marketPlace.getRefundAmount.call(subscriberRefund,dataExpiredAndPunished);
    assert.equal(refund.toNumber(),0,"refund not 0");
    // verify balances updated in the EnigmaToken
    let subscriberBalance = await enigma.balanceOf.call(subscriberRefund);
    let providerBalance = await enigma.balanceOf.call(expiredAndPunishedOwner);
    assert.equal(subscriberBalance.toNumber(),initialBalRefund - priceExpiredAndPunished/relativePunish,"ENG subscriber wrong balance");
    assert.equal(providerBalance.toNumber(),priceExpiredAndPunished/relativePunish,"ENG provider wrong balanc");
  });

  if(simple && system_test && true)
    it("Should register 2 subscribers to 3 data setes",async function(){
      let enigma = await EnigmaToken.deployed();
      let marketPlace = await Marketplace.deployed();
      // approve the Marketplace contract as a spender
      await enigma.approve(marketPlace.address,price1,{from:subscriber1});
      await enigma.increaseApproval(marketPlace.address,price2,{from:subscriber1});
      await enigma.approve(marketPlace.address,price3,{from:subscriber2});
      let allowance1 = await enigma.allowance(subscriber1,marketPlace.address);
      let allowance2 = await enigma.allowance(subscriber2,marketPlace.address);
      assert.equal(allowance1.toNumber(),price1+price2,"allowed is not equal to price");
      assert.equal(allowance2.toNumber(),price3,"allowed is not equal to price");
      // subscribe to data 
      await marketPlace.subscribe(data1,{from:subscriber1});
      await marketPlace.subscribe(data2,{from:subscriber1});
      await marketPlace.subscribe(data3,{from:subscriber2});
      // validate subscription details 
      let subscription1 = await marketPlace.checkAddressSubscription.call(subscriber1,data1);
      let subscription2 = await marketPlace.checkAddressSubscription.call(subscriber1,data2);
      let subscription3 = await marketPlace.checkAddressSubscription.call(subscriber2,data3);
      let s1 = parseSubscription(subscription1);
      let equal = isEqualSubscriptions(s1,{subscriber:subscriber1,dataName:data1,price:price1,isUnExpired:true,isPaid:false,isPunishedProvider:false,isOrder:true});
      assert.equal(equal,true,"Subscription1 is not equal");
      let s2 = parseSubscription(subscription2);
      equal = isEqualSubscriptions(s2,{subscriber:subscriber1,dataName:data2,price:price2,isUnExpired:true,isPaid:false,isPunishedProvider:false,isOrder:true});
      assert.equal(equal,true,"Subscription2 is not equal");
      let s3 = parseSubscription(subscription3);
      equal = isEqualSubscriptions(s3,{subscriber:subscriber2,dataName:data3,price:price3,isUnExpired:true,isPaid:false,isPunishedProvider:false,isOrder:true});
      assert.equal(equal,true,"Subscription3 is not equal");
    });

  if(simple && mock && system_test && true)
    it("Should try subscribing to an expired and punished data set and fail",async function(){
      let marketPlace = await Marketplace.deployed();
      try{
        await marketPlace.subscribe(expiredAndPunishedOwner,{from:subscriber3});
        assert.equal(false,true,"not error thrown");
      } catch(e){ 
        return true;
      }
    });
  if(simple && mock && system_test && true)
    it("Should test for an expired subscription",async function(){
      let marketPlace = await Marketplace.deployed();
      let subsInfo = await marketPlace.checkAddressSubscription.call(subscriberRefund,dataExpiredAndPunished);
      let isExpired = await marketPlace.isExpiredSubscription.call(subscriberRefund,dataExpiredAndPunished);
      let isValid = parseSubscription(subsInfo).isUnExpired;
      assert.equal(isExpired, !isValid , "functions are not persistent");
      assert.equal(isExpired,true, "subscription is not expired");
    })

  if(simple && system_test && true)
    it("Should try withdraw un-expired order",async function(){
      let marketPlace = await Marketplace.deployed();
      try{
        await marketPlace.withdrawProvider(data1,{from:owner1});
        assert.equal(false,true,"not error thrown");
      }catch(e){
        return true;
      }
    });
  if(simple && system_test && true)
    it("Should try refund un punished subscription",async function(){
      let marketPlace = await Marketplace.deployed();
      let zero = await marketPlace.getRefundAmount.call(subscriber1,data1);
      assert.equal(0,zero,"Bad refund amount");
      try{
        await marketPlace.refundSubscriber(data1,{from:subscriber1});
        assert.equal(false,true,"not error thrown");
      }catch(e){
        return true;
      }
    });
  if(simple && system_test && true)
    it("Should change owner", async function(){
      let marketPlace = await Marketplace.deployed();
      let current = await marketPlace.mOwner.call();
      await marketPlace.transferOwnership(subscriber2,{from:accounts[0]});
      current = await marketPlace.mOwner.call();
      assert.equal(current,subscriber2,"Ownership did not change");
      await marketPlace.transferOwnership(accounts[0],{from:subscriber2});
      current = await marketPlace.mOwner.call();
      assert.equal(current,accounts[0],"Ownership did not change back");
    });
  if(simple && system_test && true)
    it("Should punish provider -> subscribe and fail -> unpunish -> subscribe",async function(){
      let enigma = await EnigmaToken.deployed();
      let marketPlace = await Marketplace.deployed();
      // approve the Marketplace contract as a spender
      await enigma.increaseApproval(marketPlace.address,price3,{from:subscriber1});
      let punish = true;
      await marketPlace.setPunishProvider(data3,punish,{from:accounts[0]});
      try{
        await marketPlace.subscribe(data3,{from:subscriber1});
        assert.equal(false,true,"Subscribed to punished provider");
      }catch(e){
         await marketPlace.setPunishProvider(data3,!punish,{from:accounts[0]});
         await marketPlace.subscribe(data3,{from:subscriber1});
         let info =await marketPlace.checkAddressSubscription.call(subscriber1,data3);
         info = parseSubscription(info);
         let res = isEqualSubscriptions(info,{subscriber:subscriber1,dataName:data3,price:price3,isUnExpired:true,isPaid:false,isPunishedProvider:false,isOrder:true});
         assert.equal(true,res,"Subscription is not equal");
      }
    });
  if(simple && system_test && true)
    it("Should update activiy", async function(){
      let isActive = false;
      let marketPlace = await Marketplace.deployed();
      await marketPlace.changeDataSourceActivityStatus(data3,isActive,{from:owner3});
      let info = await marketPlace.getDataProviderInfo.call(data3);
      assert.equal(isActive,parseProvider(info).isActive,"Activity did not change");
      await marketPlace.changeDataSourceActivityStatus(data3,!isActive,{from:owner3});
      info = await marketPlace.getDataProviderInfo.call(data3);
      assert.equal(!isActive,parseProvider(info).isActive,"Activity did not change");
    });
  if(simple && system_test && true)
    it("should change providers price",async function(){
      let newPrice = 120;
      let marketPlace = await Marketplace.deployed();
      await marketPlace.updateDataSourcePrice(data1,newPrice,{from:owner1});
      let info = await marketPlace.getDataProviderInfo(data1);
      assert.equal(parseProvider(info).price,newPrice,"price did not change");
    });
  if(simple && system_test && true)
    it("Should register in a loop",async function(){ 
      let registers = ["SomeData1","SomeData2","SomeData3","SomeData4","SomeData5","SomeData6",
      "SomeData7","SomeData8","SomeData9","SomeData1a","SomeData11","SomeData12","SomeData13","SomeData14"];
      let price = [112,113,114,115,116,117, 201,202,203,204,205,206,207,208];
      marketPlace = await Marketplace.deployed();
      registers.forEach(async function(r,idx){
        await marketPlace.register(r,price[idx],owner1,{from:accounts[0]});
        let info = await marketPlace.getDataProviderInfo.call(r);
        assert.equal(parseProvider(info).price,price[idx],"Names dont equal");
      });
      let all = await marketPlace.getAllProviders.call();
      let totalProviders = 18;
      if(!mock)
        totalProviders = 17;
      assert.equal((all.length-2), totalProviders , "Providers not fully registerd");
    });
  if(simple && system_test && true)
    it("Should subscribe in a loop and check volume/subscriptions ",async function(){
      let data = "SomeData1";
      let price = 112;
      let subsNum = 10;
      let marketPlace = await Marketplace.deployed();
      let enigma = await EnigmaToken.deployed();
      await enigma.approve(marketPlace.address,price*subsNum, {from:subscriber1});
      for(var i=0;i<subsNum;++i){
        await marketPlace.subscribe(data,{from:subscriber1});
      }
      let providerInfo = await marketPlace.getDataProviderInfo.call(data);
      providerInfo = parseProvider(providerInfo);
      assert.equal(providerInfo.subscriptionsNum,subsNum,"Subscriptions number not equal");
      assert.equal(providerInfo.volume, subsNum * price , "Volume dont match");
    });
  if(simple && system_test && true)
  it("Should check subscription that don't exist",async function(){
      let randomAddress = '0x5aeda56215b167893e80b4fe645ba6d5bab767de';
      let marketPlace = await Marketplace.deployed();
      let sub1 = await marketPlace.checkAddressSubscription.call(randomAddress,data1);
      assert.equal(parseSubscription(sub1).isOrder,false,"Order exist");
  });
if(simple && system_test && recoverable && true)
  it("[Recover] Should get providers size",async function(){
    let marketPlace = await Marketplace.deployed();
    let providersSize = await marketPlace.getProviderNamesSize.call();
    let original = await marketPlace.getAllProviders.call();
    if(mock){
       assert.equal(original.length-2,providersSize.toNumber(),"Providers size not equal");
    }else{
          assert.equal(original.length-1,providersSize.toNumber(),"Providers size not equal");
    }
  });
if(simple && system_test && recoverable && true)
  it("[Recover]Should get Subscription size", async function(){
    let marketPlace = await Marketplace.deployed();
    let expectedSize = 10; // loop test
    let name = "SomeData1";
    let ordersSize = await marketPlace.getSubscriptionsSize.call(name);
    assert.equal(ordersSize.toNumber(),expectedSize,"Orders number don't match");
  });
if(simple && system_test && recoverable && true)
  it("[Recover] Should get Provider name at index", async function(){
    let marketPlace = await Marketplace.deployed();
    let name = await marketPlace.getNameAt.call(2);
    assert.equal(data2,utils.toAscii(name),"Names don't equal");

  });
if(simple && system_test && recoverable && true)
  it("[Recover] check subscription at",async function(){
    let marketPlace = await Marketplace.deployed();
    let subscription = await marketPlace.checkSubscriptionAt.call(data1,0);
    assert.equal(parseSubscription(subscription).subscriber , subscriber1, "Subscription dont fit");
    assert.equal(parseSubscription(subscription).isUnExpired, true , "Subscription expiration date incorrect");
  });
if(simple && system_test && recoverable && true)
  it("[Recover] Should check if a subscription is expired", async function(){
    let marketPlace = await Marketplace.deployed();
    let isExpired = await marketPlace.isExpiredSubscriptionAt.call(data1,0);
    assert.equal(isExpired, false, "Subscription expiration incorrect");
  });
if(simple && system_test && recoverable && true)
  it("[Recover] should register a provider",async function(){
    let marketPlace = await Marketplace.deployed();
    await marketPlace.register(dataRecoverName,priceRecover,recoverOwner,{from : recoverOwner});
    let size = await marketPlace.getProviderNamesSize.call();
    let nameTest = await marketPlace.getNameAt(size.toNumber() -1);
    assert.equal(utils.toAscii(nameTest), dataRecoverName, "Names dont match");

  });
if(simple && mock && system_test && recoverable && true)
  it("[Recover]Register (mock) expired data set, refund and withdraw",async function(){
    let withTx = true; // mock function meaninig: do actual token transfer on subscription
    let relativePunish = 2; // meaning => provider got punished half way through the subscription
    let enigma = await EnigmaToken.deployed();
    let marketPlace = await Marketplace.deployed();
    // test regular subscription - not expired and not punished
    await enigma.approve(marketPlace.address,price1,{from:subscriberRecover});
    let tx= await marketPlace.subscribe(data1,{from:subscriberRecover}); 
    // approval ENG with Marketplace protocol
    await enigma.approve(marketPlace.address,priceExpiredRecoverd,{from:subscriberRecover});
    // mock => register expired and punished subscription + addsubscriber 
    await marketPlace.mockPayableProvider(
          dataExpiredRecover,
          priceExpiredRecoverd,
          expiredRecoverOwner,
          true,
          relativePunish,
          withTx,
          {from:subscriberRecover});
    // get available withdraw 
    let subsSize = await marketPlace.getSubscriptionsSize.call(dataExpiredRecover);
    for(var i=0;i<subsSize.toNumber();++i){
      let withdraw = await marketPlace.getWithdrawAmountAt.call(dataExpiredRecover,i);
      assert.equal(withdraw.toNumber(),priceExpiredRecoverd/relativePunish,"Withdraw get not equal");
    }
    // get available refund
    for(var i=0;i<subsSize.toNumber();++i){
      let subscription = await marketPlace.checkSubscriptionAt.call(dataExpiredRecover,i);
      let isPunished = parseSubscription(subscription).isPunishedProvider;
      assert.equal(isPunished,true,"Punishment did not set ");
      let refund = await marketPlace.getRefundAmountAt.call(dataExpiredRecover,i);
      assert.equal(refund.toNumber(),priceExpiredRecoverd/relativePunish,"Refund not equal");
    }
    // withdraw 
    await marketPlace.withrawProviderAt(dataExpiredRecover,0,{from:expiredRecoverOwner});
    let ownerBal = await enigma.balanceOf(expiredRecoverOwner);
    assert.equal(ownerBal.toNumber(),priceExpiredRecoverd/relativePunish,"provider balance dont match");
    // refund
    await marketPlace.refundSubscriberAt(dataExpiredRecover,0,{from:subscriberRecover});
    let refundBal = await enigma.balanceOf(subscriberRecover);
    let price1New = 120;
    assert.equal(refundBal.toNumber(),initialRecoverBal -(priceExpiredRecoverd/relativePunish)-price1New,"Refund balance dont match");
     // get available withdraw 
    subsSize = await marketPlace.getSubscriptionsSize.call(dataExpiredRecover);
    for(var i=0;i<subsSize.toNumber();++i){
      let withdraw = await marketPlace.getWithdrawAmountAt.call(dataExpiredRecover,i);
      assert.equal(withdraw.toNumber(),0,"Withdraw get not equal");
    }
    // get available refund
    for(var i=0;i<subsSize.toNumber();++i){
      let subscription = await marketPlace.checkSubscriptionAt.call(dataExpiredRecover,i);
      let isPunished = parseSubscription(subscription).isPunishedProvider;
      assert.equal(isPunished,true,"Punishment did not set ");
      let refund = await marketPlace.getRefundAmountAt.call(dataExpiredRecover,i);
      assert.equal(refund.toNumber(),0,"Refund not equal");
    }
  });
  //
});

function parseSubscription(info){
  var normal = {};
  normal.subscriber = info[0];
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
  console.log("subscriber : " +s.subscriber );
  console.log("dataName : " +s.dataName );
  console.log("price : " + s.price);
  console.log("startTime : " + s.startTime);
  console.log("endTime : " +s.endTime );
  console.log("isUnExpired : " + s.isUnExpired);
  console.log("isPaid : " + s.isPaid);
  console.log("isPunishedProvider : " + s.isPunishedProvider);
  console.log("isOrder : " + s.isOrder);
}
function isEqualProvider(p1,p2){
  return p1.owner == p1.owner &&
  p1.price == p1.price &&
  p1.volume == p1.volume &&
  p1.subscriptionsNum ==p1.subscriptionsNum &&
  p1.isProvider ==p1.isProvider &&
  p1.isActive ==p1.isActive &&
  p1.isPunished ==p1.isPunished;
}
function parseProvider(info){
  var pro = {};
  pro.owner = info[0];
  pro.price = info[1].toNumber();
  pro.volume = info[2].toNumber();
  pro.subscriptionsNum = info[3].toNumber();
  pro.isProvider =info[4];
  pro.isActive = info[5];
  pro.isPunished = info[6];
  return pro;
}
function printProviderInfo(info){
        var p = parseProvider(info);
        console.log("owner: " + p.owner);
        console.log("price : " + p.price);
        console.log("volume : " + p.volume);
        console.log("subscsnum : " + p.subscriptionsNum);
        console.log("isProvider: " +p.isProvider );
        console.log("isActive : " + p.isActive);
        console.log("isPunished : " +p.isPunished );
}


