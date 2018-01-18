pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DummyToken.sol";


contract TestDummyToken {
  function testInitialBalanceUsingDeployedDummyToken() public{
    DummyToken token = DummyToken(DeployedAddresses.DummyToken());
    uint expected = 10000;
    Assert.equal(token.balanceOf(tx.origin),expected, "Owner should have 10,000 Dummy Coin");
  }

  function testDummyTokenTransfer() public{
    DummyToken token = DummyToken(DeployedAddresses.DummyToken());
    address to = token.getTest();
    uint amount = 10;
    bool result = token.transfer(to,amount);
    Assert.equal(result,true,"Token Transfer didnt happend correctly");
    uint expected = 10;
    Assert.equal(token.balanceOf(to),expected, "Recieving balance not as expected after transfer");
    Assert.equal(token.balanceOf(tx.origin),10000-expected, "Senders balance not as expected after transfer"); 
  }
}
