
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");
var MarketPlace = artifacts.require("./MarketPlace.sol");
var utils = require("./utils");

contract('MarketPlace',(accounts)=>{


  // #1
if (true)
  it("Should return the EnigmaToken owner balance via the MarketPlace contract", ()=>{
    return MarketPlace.deployed().then(instance=>{return instance.balanceOf.call(accounts[0])}).
      then((balance)=>{assert.equal(balance,10000,"Owner Balance is incorrect");});
  });
  
// #2
// works fine alone, conflict with #3
//params{dataName,price,ownerAddress,fromTX}
if (true)
  it("Should Register a new data Provider",()=>{
    MarketPlace.deployed().then(instance=>{
      utils.registerAndThen(instance,{dataName:"DataSet1",price:100,ownerAddress:accounts[1],fromTX:accounts[0]},(marketPlace,p)=>{});
    });
  });

  // #3
if(false)
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
  // coupled with #2 (Dataset namedependency)
if(true)
  it("Should get Owner Name",()=>{
    var dataSet = "DataSet1";
    var addr1 = accounts[1];
    return MarketPlace.deployed().then((instance)=>{
      return instance.getOwnerFromName.call(dataSet);
    }).then((addr)=>{
      assert.equal(addr,addr1);
    });
  });                                                                                                                                                                                                                                                                                                                                                   
  

  // #5
  // coupled with #2
if(true)
  it("Should get data source details",()=>{
    var dataSet = "DataSet1";
    var addrBase = accounts[1];
    return MarketPlace.deployed().then((instance)=>{
      marketPlace = instance;
      return instance.getOwnerFromName.call(dataSet);
    }).then((addr)=>{
      assert.equal(addr,addrBase);
      return marketPlace.getDataSource(dataSet);
    }).then(dataSourceDetails=>{
      var owner = dataSourceDetails[0];
      var price = dataSourceDetails[1].toNumber();
      var volume = dataSourceDetails[2].toNumber();
      var subscriptions = dataSourceDetails[3].toNumber();
      assert.equal(owner,addrBase,"Address of the data source do not match");
      assert.equal(price, 100 , "Prices of the data source do not match" );
      assert.equal(volume,0,"Volumes of the data source don't match");
      assert.equal(subscriptions,0,"Subsction numbers of the data source do not match ");
    });
  });

    // #6
    // couple with #2
  if(true)
    it("Should update a data source price ",()=>{
      var newPrice = 25;
      var dataSet = "DataSet1";
      var owner = accounts[1];
      return MarketPlace.deployed().then(instance=>{
        marketPlace = instance;
        return marketPlace.updateDataSourcePrice(dataSet,newPrice, {from:owner});
      }).then(tx=>{
        utils.assertEvent(marketPlace,{event:"PriceUpdate"},(event=>{
          var afterPrice = event[0].args.newPrice;
          var afterName = event[0].args.dataSourceName;
          var afterEditor = event[0].args.editor;
          assert.equal(afterPrice,newPrice,"New Price did not update");
          assert.equal(utils.toAscii(afterName),dataSet," Data source name dont match");
          assert.equal(afterEditor,owner,"Edited not by owner");
        }));
      })
    }); 

    // #7 coupled with #2
if(true)
  it("Should Approve and Subscribe to the marketplace provider",()=>{
    var provider = accounts[1];
    var subscriber = accounts[0];
    var dataPrice = 25;
    var dataSetName = "DataSet1";
    return EnigmaToken.deployed().
      then((instance)=>{enigmaToken = instance; return MarketPlace.deployed();}).
        then((instance)=>{marketPlace = instance; return enigmaToken.approve(marketPlace.address,dataPrice,{from:subscriber});}).
          then(tx=>{utils.assertEvent(enigmaToken,{event:"Approval"},(event)=>{
              var res = marketPlace.subscribe(dataSetName,{from:subscriber});
              utils.assertEvent(marketPlace,{event:"Subscribed"},event=>{ 
                new Promise((resolve,reject)=>{
                  var result= marketPlace.checkAddressSubscription.call(subscriber,dataSetName);
                  resolve(result);
                }).then(subscriptionInfo=>{
                    var resAddr = subscriptionInfo[0];
                    var resName = utils.toAscii(subscriptionInfo[1]);
                    var resPrice = subscriptionInfo[2];
                    var resStartTime = subscriptionInfo[3];
                    var resEndTime = subscriptionInfo[4];
                    assert.equal(resAddr,subscriber,"Addresses dont match in subscription info");
                    assert.equal(resName,dataSetName, "Names dont match in the subscription info");
                    assert.equal(resPrice,dataPrice,"Prices dont match in the subscription info");
                    //TODO:: check valid subscription time
                }).then(()=>{return enigmaToken.balanceOf.call(provider);}).
                    then(balance=>{assert.equal(balance.toNumber(),dataPrice,"Providers balance isnt updated");}).
                      then(()=>{return marketPlace.getDataSource.call(dataSetName);}).
                          then(dataSourceInfo=>{
                            console.log(JSON.stringify(dataSourceInfo,null,2));
                            var owner = dataSourceInfo[0];
                            var price = dataSourceInfo[1].toNumber();
                            var volume = dataSourceInfo[2].toNumber();
                            var subscriptions = dataSourceInfo[3].toNumber();
                            var isSource = dataSourceInfo[4];
                            assert.equal(owner,provider,"Address of the data source do not match");
                            assert.equal(price, dataPrice , "Prices of the data source do not match" );
                            assert.equal(volume,dataPrice,"Volumes of the data source don't match");
                            assert.equal(subscriptions,1,"Subsction numbers of the data source do not match ");
                            assert.equal(isSource,true,"Subscription is not source.")
                          });
              });
          })});
  }); 
}); 
