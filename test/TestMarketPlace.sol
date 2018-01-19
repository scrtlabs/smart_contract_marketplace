pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/token/EnigmaToken.sol";
import "../contracts/MarketPlace.sol";


contract TestMarketPlace 
{
  function testMarketPlaceRegistration() public
  {
    EnigmaToken token = EnigmaToken(DeployedAddresses.EnigmaToken());
    MarketPlace marketPlace = new MarketPlace(DeployedAddresses.EnigmaToken(),now);
    bytes32 dataSource = "name1";
    bool result = marketPlace.register(dataSource,150,msg.sender);
    address addr = marketPlace.getOwnerFromName(dataSource);
    Assert.equal(result,true,"Registration didnt work");
    Assert.equal(addr,msg.sender,"Datasource dont exist after registration");
  }

  function testMarketPlace2NameRegistration() public 
  {
    EnigmaToken token = EnigmaToken(DeployedAddresses.EnigmaToken());
    MarketPlace marketPlace = new MarketPlace(DeployedAddresses.EnigmaToken(),now);
    bytes32 name1 = "name1";
    bytes32 name2 = "name2";
    bool name1Result = marketPlace.register(name1,150,msg.sender);
    bool name2Result = marketPlace.register(name2,100,msg.sender);
    Assert.equal(name1Result,true,"name1 couldnt register");
    Assert.equal(name2Result,true,"name2 couldnt register");
    address addr1 = marketPlace.getOwnerFromName(name1);
    address addr2 = marketPlace.getOwnerFromName(name2);
    Assert.equal(addr1,msg.sender,"name1 address didnt return");
    Assert.equal(addr2,msg.sender,"name2 address didnt return");
  }
  // throws error since the name is not unique and revert (should be tested in outside solidity)
  // function testMarketPlaceSameNameRegistration() public{
  //   EnigmaToken token = EnigmaToken(DeployedAddresses.EnigmaToken());
  //   MarketPlace marketPlace = new MarketPlace(DeployedAddresses.EnigmaToken(),now);
  //   bytes32 dataSource = "name1";
  //   marketPlace.register(dataSource,150,msg.sender);
  //   bool result = marketPlace.register(dataSource,162,msg.sender);
  //   Assert.equal(result,false,"Same name was registred twice");
  // }
}
