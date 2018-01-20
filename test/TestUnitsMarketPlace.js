
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");
var MarketPlace = artifacts.require("./MarketPlace.sol");
var utils = require("./utils");

contract('MarketPlace',(accounts)=>{


  // #1
if (false)
  it("Should return the EnigmaToken owner balance via the MarketPlace contract", ()=>{
    return MarketPlace.deployed().then(instance=>{marketPlace = instance; return instance.getSubscrioption.call()}).
      then((period)=>{
        console.log("The subscription period 1 month = " + period);
        return marketPlace.getSubscrioptionFinishDate.call();
      }).then((finishDate)=>{
        console.log("The finish date of the subscription 1 month + now = " + finishDate);
    });
  });

}); 
