var Marketplace = artifacts.require("./Marketplace.sol");

contract('Marketplace', function(accounts) {
  it("Should add Data Provider 1 ",function(){
    return Marketplace.deployed().then(instance=>{
      marketPlace = instance;
      return instance.register("data1",100,accounts[0],{from:accounts[0]});
    }).then(tx=>{
      return marketPlace.register("data2",200, accounts[0],{from:accounts[0]});
    }).then(tx=>{
    	return marketPlace.getAllProviders.call();
    }).then(list=>{
    	console.log(list);
    });
  });
});
