var DummyToken = artifacts.require("./DummyToken.sol");
var MarketPlace = artifacts.require("./MarketPlace.sol");

module.exports = function(deployer) {
  deployer.then(()=>{
  	return deployer.deploy(DummyToken);
  }).then(()=>{
  	return DummyToken.deployed();
  }).then(tokenInstance=>{
  	return deployer.deploy(MarketPlace, tokenInstance.address);
  });
};
