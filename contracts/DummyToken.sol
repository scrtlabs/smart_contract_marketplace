pragma solidity ^0.4.18;
/*
	Dummy Token for Testing purposes - to be deleted.
*/
import "./ERC20Interface.sol";

contract DummyToken is ERC20Interface
{

 string public constant name = "DummyToken";
 string public constant symbol = "DT";
 uint8 public constant decimals = 18;
 uint public constant total_supply = 10000;
 address public owner;
 address public test;
 mapping(address => uint256) balances;
 mapping(address => mapping (address => uint256)) allowed;

 function DummyToken(address _test) public
 {
 	test = _test;
 	owner = msg.sender;
 	balances[owner] = total_supply;
 }
 function totalSupply() public constant returns (uint)
 {
 	return total_supply;
 }

 function balanceOf(address who) public constant returns (uint256)
 {
 	return balances[who];
 }
 function transfer(address to, uint value) public returns (bool)
 {
 	// 
 	//require(balances[msg.sender] >= tokens);
 	test = msg.sender;
 	balances[msg.sender] -= value;
 	balances[to] += value;
 //	Transfer(msg.sender, to, value);
 	return true;
 }
 function getTest() public returns (address){
 	return test;
 }
 function transferFrom(address from, address to, uint tokens) public returns (bool success){return true;}
 function approve(address spender, uint tokens) public returns (bool success){return true;}
 function allowance(address tokenOwner, address spender) public constant returns (uint remaining){return uint(0);}
}