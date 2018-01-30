pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/token/EnigmaToken.sol";

contract TestEnigmaToken {

  function testInitialBalanceUsingDeployedEnigmaToken() public{
    EnigmaToken token = EnigmaToken(DeployedAddresses.EnigmaToken());
    uint init_expected = 10000;
    Assert.equal(token.balanceOf(tx.origin),init_expected, "Owner should have 10,000 EnigmaToken");
  }

}
