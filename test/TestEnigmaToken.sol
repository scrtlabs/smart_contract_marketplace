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

  // bad because contract cannot transfer. - dont work obviously
  // function testEnigmaTokenTransfer() public{
  //   int init_expected = 10000;
  //   EnigmaToken token = EnigmaToken(DeployedAddresses.EnigmaToken());
  //   address to = token.getTest();
  //   uint amount = 10;
  //   bool result = token.transfer(to,amount);
  //   Assert.equal(result,true,"Token Transfer didnt happend correctly");
  //   uint expected = 10;
  //   Assert.equal(token.balanceOf(to),expected, "Recieving balance not as expected after transfer");
  //   Assert.equal(token.balanceOf(tx.origin),10000-expected, "Senders balance not as expected after transfer"); 
  // }
}
