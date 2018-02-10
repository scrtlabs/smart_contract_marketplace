
var utils = require("../scripts/utils");
var Marketplace = artifacts.require("./Marketplace.sol");
//var Marketplace = artifacts.require("./mocks/TestableMock.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");


const simple = false;
const mock = false;


contract('Marketplace Recovery', function(accounts) {
if(simple && true)
  it("Should subscribe to max block limit ", async function(){
    let regNum = 5000;
    let enigma = await EnigmaToken.deployed();
    let owner = accounts[0];
    let marketPlace = await Marketplace.deployed();
    for(var i=0;i < regNum; i++){
      await marketPlace.register((i+1+"Name"),1,owner,{from:owner});
      try{
        let providers = await marketPlace.getAllProviders.call();
        assert.equal(i+2,providers.length, "Provider dit not register");
        if(i % 10 == 0){
          console.log(i+1);
        }
      }catch(e){
        console.log("Max providers number = " + (i-1));
      }
    }
    
  });
  //
});






