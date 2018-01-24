var MarketPlace = artifacts.require("./Marketplace.sol");
var EnigmaToken = artifacts.require("./token/EnigmaToken.sol");
var SafeMath = artifacts.require("./zeppelin-solidity/SafeMath.sol");

module.exports = function(deployer) {
  deployer.then(()=>{
  	var addr2= '0xf17f52151EbEF6C7334FAD080c5704D77216b732';
  	return deployer.deploy(EnigmaToken,addr2);
  }).then(()=>{
  	return EnigmaToken.deployed();
  }).then(tokenInstance=>{
  	return deployer.deploy(MarketPlace, tokenInstance.address);
  });
};
