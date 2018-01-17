pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DummyToken.sol";
import "../contracts/MarketPlace.sol";


contract TestMarketPlace {
  function testNewMarletPlaceImplementation() public{
    DummyToken token = DummyToken(DeployedAddresses.DummyToken());
    MarketPlace marketPlace = new MarketPlace(DeployedAddresses.DummyToken(),now);
    bool result = marketPlace.subscribe(bytes32("a"));
    Assert.equal(result,true,"test didnt return true");
  }
}
