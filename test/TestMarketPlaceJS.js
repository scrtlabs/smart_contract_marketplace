
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");
var MarketPlace = artifacts.require("./MarketPlace.sol");
var utils = require("./utils");

contract('MarketPlace',(accounts)=>{
  it("Should return the EnigmaToken owner balance via the MarketPlace contract", ()=>{
    return MarketPlace.deployed().then(instance=>{ return instance.balanceOf.call(accounts[0])}).
      then((balance)=>{assert.equal(balance,10000,"Owner Balance is incorrect");});
  });

//approve(address _spender, uint256 _value) 
  it("Should subscribe to a dataProvider and validate transaction",()=>{
    var subscriber = accounts[0];
    var provider = accounts[1];
    var allowedAmount = 500;
    return MarketPlace.deployed().then(instance=>{
      marketPlace = instance;
    }).then(()=>{
      return EnigmaToken.deployed().then((instance)=>{
        enigmaToken = instance;
        return enigmaToken.approve(marketPlace.address,allowedAmount,{from:subscriber});
      }).then(()=>{
        utils.assertEvent(enigmaToken,{event:"Approval"},(event=>{
          var approved =  assertApprovalEvent(event,{amount:allowedAmount,owner:subscriber,spender:marketPlace.address});
          assert.equal(approved,true,"Allowance not completley allowed.");
            new Promise((resolve, reject)=> {
              var res = enigmaToken.allowance.call(subscriber,marketPlace.address);
              resolve(res);
            }).then(allowanceAmount=>{
                assert.equal(allowanceAmount,allowedAmount,"allowace did not update in enigmaToken");  
               return marketPlace.atomicTransfer(subscriber, provider, allowanceAmount);
            }).then(tx=>{
                utils.assertEvent(marketPlace,{event:"SubscriptionPaid"},(event)=>{
                  new Promise((resolve,reject)=>{
                    var res = enigmaToken.balanceOf.call(provider);
                    resolve(res);
                  }).then(balance=>{
                    assert.equal(balance.toNumber(),allowedAmount,"Provider did not reviece the amount subcribed for");
                  });
                });
            });
        }));
      });
    });
  });

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

function assertApprovalEvent(event,params){
  var owner = event[0].args.owner;
  var spender = event[0].args.spender;
  var amount = event[0].args.value.toNumber();
  console.log("approval event details:");
  console.log("owner: ", owner);
  console.log("spemder: ", spender);
  console.log("amount: ", amount);
  assert.equal(params.amount,amount,"allowed amount is not corrent");
  assert.equal(params.owner,owner,"owner address is not correct");
  assert.equal(params.spender,spender,"spender address is not correct");
  return true;
}