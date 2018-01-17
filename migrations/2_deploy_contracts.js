var DummyToken = artifacts.require("./DummyToken.sol");
var MarketPlace = artifacts.require("./MarketPlace.sol");

module.exports = function(deployer) {
  deployer.then(()=>{
  	var addr2= '0xf17f52151EbEF6C7334FAD080c5704D77216b732';
  	return deployer.deploy(DummyToken,addr2);
  }).then(()=>{
  	return DummyToken.deployed();
  }).then(tokenInstance=>{
  	return deployer.deploy(MarketPlace, tokenInstance.address);
  });
};
