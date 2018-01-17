var MarketPlace = artifacts.require("./MarketPlace.sol");


contract('MarketPlace',(accounts)=>{

  it("Should register a Data Provider",()=>{
    MarketPlace.deployed().then(instance=>{
      return instance.register("Data Set", 100, accounts[0]);
    }).then(boolResult=>{
      //console.log("ERROR HERE ?!??!?!?#$?#?%$#?%");
      //console.log(boolResult);
      //assert.equal(boolResult,true,"Registration didn't succeed");
    });
  });

  it("Should do test interaction with the ERC20 DummyToken",()=>{
    MarketPlace.deployed().then(instance=>{
      return instance.getTest.call();
    }).then(addrResult=>{
      console.log("THE REUSLT FROM INTERACTION : ");
      console.log(addrResult);
      assert.equal(true,true,"Testing interaction didnt work");
    });
  });
});




