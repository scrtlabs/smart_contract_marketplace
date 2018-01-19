
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");
var MarketPlace = artifacts.require("./MarketPlace.sol");
var utils = require("./utils");

contract('MarketPlace',(accounts)=>{

  // #1
  it("Should return the EnigmaToken owner balance via the MarketPlace contract", ()=>{
    return MarketPlace.deployed().then(instance=>{return instance.balanceOf.call(accounts[0])}).
      then((balance)=>{assert.equal(balance,10000,"Owner Balance is incorrect");});
  });

  
// #2
// works fine alone, conflict with #3
//params{dataName,price,ownerAddress,fromTX}
  // it("Should Register a new data Provider",()=>{
  //   MarketPlace.deployed().then(instance=>{
  //     utils.registerAndThen(instance,{dataName:"DataSet",price:100,ownerAddress:accounts[1],fromTX:accounts[0]},(marketPlace,p)=>{});
  //   });
  // });

  // #3
  it("Should Register 2 names under the same address(owner)", ()=>{
    var addr1_owner,addr2_owner;
    var registerOne = {dataName: "DataSet1",price:100,ownerAddress:accounts[1],fromTX: accounts[0]};
    var registerTwo = {dataName:"DataSet2",price:200,ownerAddress:accounts[1],fromTX: accounts[0]};
    MarketPlace.deployed().then((instance)=>{
      marketPlace = instance;
      utils.registerAndThen(marketPlace,registerOne,(marketPlace,p)=>{
      utils.registerAndThen(marketPlace,registerTwo,(marketPlace,p)=>{
          new Promise((resolve,reject)=>{
            var res = marketPlace.getOwnerFromName.call(registerOne.dataName);
            resolve(res);
          }).then(addr1=>{
            addr1_owner = addr1;
            return marketPlace.getOwnerFromName.call(registerTwo.dataName);
          }).then(addr2=>{
            addr2_owner = addr2;
            assert.equal(addr1_owner,addr2_owner, "Data owners dont match in contract");
            assert.equal(addr1_owner,registerOne.ownerAddress, "Data owners dont match in origin");          
          });
      });
    });
    });
  });
  // #4 
  // couple with #3 (Dataset namedependency)
  it("Should get Owner Name",()=>{
    var dataSet = "DataSet1";
    var addr1 = accounts[1];
    return MarketPlace.deployed().then((instance)=>{
      return instance.getOwnerFromName.call(dataSet);
    }).then((addr)=>{
      assert.equal(addr,addr1);
    });
  });
  
  //function getDataSource(bytes32 _dataSourceName) public view returns(address,bytes32,uint,bool)
  // #5
  it("Should get data source details",()=>{
    var dataSet = "DataSet1";
    var addrBase = accounts[1];
    return MarketPlace.deployed().then((instance)=>{
      marketPlace = instance;
      return instance.getOwnerFromName.call(dataSet);
    }).then((addr)=>{
      assert.equal(addr,addrBase);
      console.log("Address actually match : " , addr);
      console.log("Should be -> " , addrBase);
      return marketPlace.getDataSource(dataSet);
    }).then(dataSourceDetails=>{
      console.log(dataSourceDetails);
    });
  });
  // SHOULD UPDATE - approves-> allowance - > TODO:: subscribe where commented
  // it("Should subscribe to a dataProvider and validate transaction",()=>{
  //   var subscriber = accounts[0];
  //   var provider = accounts[1];
  //   var allowedAmount = 500;
  //   return MarketPlace.deployed().then(instance=>{
  //     marketPlace = instance;
  //   }).then(()=>{
  //     return EnigmaToken.deployed().then((instance)=>{
  //       enigmaToken = instance;
  //       return enigmaToken.approve(marketPlace.address,allowedAmount,{from:subscriber});
  //     }).then(()=>{
  //       utils.assertEvent(enigmaToken,{event:"Approval"},(event=>{
  //         var approved =  utils.assertApprovalEvent(event,{amount:allowedAmount,owner:subscriber,spender:marketPlace.address});
  //         assert.equal(approved,true,"Allowance not completley allowed.");
  //           new Promise((resolve, reject)=> {
  //             var res = enigmaToken.allowance.call(subscriber,marketPlace.address);
  //             resolve(res);
  //           }).then(allowanceAmount=>{
  //               assert.equal(allowanceAmount,allowedAmount,"allowace did not update in enigmaToken");  
  //               // here i know that actually allowed to transfer and can subscribe to some data source
  //              // return marketPlace.atomicTransfer(subscriber, provider, allowanceAmount);
  //           }).then(tx=>{
  //               utils.assertEvent(marketPlace,{event:"SubscriptionPaid"},(event)=>{
  //                 new Promise((resolve,reject)=>{
  //                   // here should grab the finished subscription event.
  //                   //var res = enigmaToken.balanceOf.call(provider);
  //                   resolve(res);
  //                 }).then(balance=>{
  //                   assert.equal(balance.toNumber(),allowedAmount,"Provider did not reviece the amount subcribed for");
  //                 });
  //               });
  //           });
  //       }));
  //     });
  //   });
  // });


});


/***********************************************************************************/
/* Util functions 
/***********************************************************************************/

