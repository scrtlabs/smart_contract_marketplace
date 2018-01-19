var MarketPlace = artifacts.require("./MarketPlace.sol");
var utils = require("./utils");

 contract('MarketPlace',(accounts)=>{

//   it("should do register and verify event was fired correctly",()=>{
//       amount = 100;
//       dataName = "Data Set";
//       return MarketPlace.deployed().then(instance=>{c = instance;instance.register(dataName, amount, accounts[0])})
//       .then(()=> utils.assertEvent(c,{event:"Registered"},(event)=>{
//          assertRegistrationEvent(event,{amount:amount,account:accounts[0],dataName:dataName},true);
//       }));
//   });

//   it("Should register two datasource's - to existing provider",()=>{
//       var amount1 = 100;
//       var amount2 = 50;
//       var dataName1 = "Data Set1";
//       var dataName2 = "Data Set2";
//       return MarketPlace.deployed().then(instance=>{c = instance;instance.register(dataName1, amount1, accounts[0])})
//       .then(()=> utils.assertEvent(c,{event:"Registered"},(event)=>{
//         assertRegistrationEvent(event,{amount:amount1,account:accounts[0],dataName:dataName1},true);
//         //so far only registered a data provider - now adding a second datasource to an existing data provider
//         return MarketPlace.deployed().then(instance=>{c = instance;instance.register(dataName2, amount2, accounts[0])})
//         .then(()=> utils.assertEvent(c,{event:"Registered"},(event)=>{
//           assertRegistrationEvent(event,{amount:amount2,account:accounts[0],dataName:dataName2},true);
//         }));        
//       }));
//   });
//   it("Should get the owners balance from the token",()=>{
//     return MarketPlace.deployed().then(instance=>{
//       return instance.balanceOf.call(accounts[0]);
//     }).then((result)=>{
//       assert.equal(result.toNumber(),10000,"Balance is not equal");
//     });
//   });
// BAD 
  // it("should send coin correctly", function() {
  //   var meta;

  //   // Get initial balances of first and second account.
  //   var account_one = accounts[0];
  //   var account_two = accounts[1];

  //   var account_one_starting_balance;
  //   var account_two_starting_balance;
  //   var account_one_ending_balance;
  //   var account_two_ending_balance;

  //   var amount = 10;

  //   return MarketPlace.deployed().then(function(instance) {
  //     meta = instance;
  //     return meta.balanceOf.call(account_one);
  //   }).then(function(balance) {
  //     account_one_starting_balance = balance.toNumber();
  //     return meta.balanceOf.call(account_two);
  //   }).then(function(balance) {
  //     account_two_starting_balance = balance.toNumber();
  //     return meta.transfer(account_two, amount, {from: account_one});
  //   }).then(function() {
  //     return meta.balanceOf.call(account_one);
  //   }).then(function(balance) {
  //     account_one_ending_balance = balance.toNumber();
  //     return meta.balanceOf.call(account_two);
  //   }).then(function(balance) {
  //     account_two_ending_balance = balance.toNumber();
  //     assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
  //     assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
  //   });
  // });

  // it("should send coin correctly THREE WAYS", function() {
  //   var meta;

  //   // Get initial balances of first and second account.
  //   var account_one = accounts[0];
  //   var account_two = accounts[1];
  //   var account_three = accounts[2];
  //   var account_one_starting_balance;
  //   var account_two_starting_balance;
  //   var account_three_starting_balance;
  //   var account_one_ending_balance;
  //   var account_two_ending_balance;
  //   var account_three_ending_balance;
  //   var account_two_finalFinal_balance;

  //   var amount = 10;

  //   return MarketPlace.deployed().then(function(instance) {
  //     meta = instance;
  //     return meta.balanceOf.call(account_one);
  //   }).then(function(balance) {
  //     account_one_starting_balance = balance.toNumber();
  //     return meta.balanceOf.call(account_two);
  //   }).then(function(balance) {
  //     account_two_starting_balance = balance.toNumber();
  //     return meta.transfer(account_two, amount, {from: account_one});
  //   }).then(function() {
  //     return meta.balanceOf.call(account_one);
  //   }).then(function(balance) {
  //     account_one_ending_balance = balance.toNumber();
  //     return meta.balanceOf.call(account_two);
  //   }).then(function(balance) {
  //     account_two_ending_balance = balance.toNumber();
  //     return meta.balanceOf.call(account_three);
  //   }).then((balance)=>{
  //     account_three_starting_balance = balance.toNumber();
  //     return meta.transfer(account_three, amount/2 ,{from:account_two});
  //   }).then(()=>{
  //     return meta.balanceOf.call(account_two);
  //   }).then(balance=>{
  //     account_two_finalFinal_balance = balance.toNumber();
  //     return meta.balanceOf.call(account_three);
  //   }).then(balance=>{
  //     account_three_ending_balance = balance.toNumber();
  //     console.log(" ----- start tx -------- ");
  //     console.log("account 1 => starting : " + account_one_starting_balance+ " ending : "+account_one_ending_balance);
  //     console.log("account 2 => starting : " + account_two_starting_balance + " middle: " + account_two_ending_balance + " ending: " + account_two_finalFinal_balance);
  //     console.log("account 3 => starting : " + account_three_starting_balance + " ending: " + account_three_ending_balance);      
  //     console.log(" ----- end tx -------- ");
  //   });
  //   //assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
  // });
  // it("Should Subscribe to an existing datasource",()=>{
  //   var dataSet = "DataSet";
  //   var price = 100;
  //   return MarketPlace.deployed().then(instance=>{
  //     marketplace = instance;
  //     marketplace.register(dataSet,price,accounts[1]);
  //   }).then(()=>{
  //     //var result = assertRegistrationEvent(c,{amount:price,account: accounts[1],dataName: dataSet},true);
  //     if(true){ // registration completed
  //       return marketplace.subscribe(dataSet).then(()=>{
  //         utils.assertEvent(marketplace,{event:"Subscribed"},(event)=>{
  //           console.log("Subscriptioned event !!!====================  START");
  //           console.log(event);
  //           console.log("Subscriptioned event !!!====================   END");
  //         })
  //       });
  //     }
  //   });
  // });
});








/***********************************************************************************/
/* Util functions 
/***********************************************************************************/

//BaseParams{amount:,account:,dataName:}
function assertRegistrationEvent(event,baseParams,successRegister){
        var result = event[0].args.success;
        var price = event[0].args.price;
        var registeringAddress = event[0].args.dataOwner;
        var dataSourceName = utils.toAscii(event[0].args.dataSourceName);
        assert.equal(result,successRegister,"Registration did not succeed first time");
        assert.equal(price.toNumber(),baseParams.amount,"Prices are not equal first time");
        assert.equal(registeringAddress,baseParams.account,"Registrerer address is not equal first time");
        assert.equal(dataSourceName,baseParams.dataName, "Data source names are not equal first time");
        return true;
}
/***********************************************************************************/
/* Tests that should be kept but not finallized in terms of correct assertion.*/
/***********************************************************************************/

/* trying to register the same name returns revet on theseond transaction - as should */
  // it("Should register an existing datasource name and fail",()=>{
  //       var amount1 = 100;
  //       var amount2 = 50;
  //       var dataName1 = "SAME";
  //       var dataName2 = "SAME";
  //       return MarketPlace.deployed().then(instance=>{c = instance;instance.register(dataName1, amount1, accounts[0])})
  //       .then(()=> utils.assertEvent(c,{event:"Registered"},(event)=>{
  //         assertRegistrationEvent(event,{amount:amount1,account:accounts[0],dataName:dataName1},true);
  //         //so far only registered a data provider - now adding a second datasource to an existing data provider
  //         return MarketPlace.deployed().then(instance=>{c = instance;instance.register(dataName2, amount2, accounts[0])})
  //         .then(()=> utils.assertEvent(c,{},(event)=>{
  //           assertRegistrationEvent(event,{amount:amount2,account:accounts[0],dataName:dataName2},true);
  //         }));        
  //       }));
  // });