pragma solidity ^0.4.18;
/*
	Standad ERC20 Token interface. 
	MarketPlace.sol uses it for interacting with the Enigma Token.
*/	
contract ERC20Interface {
 function totalSupply() public constant returns (uint);
 function balanceOf(address who) public constant returns (uint256);
 function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
 function transfer(address to, uint value) public returns (bool);
 function approve(address spender, uint tokens) public returns (bool success);
 function transferFrom(address from, address to, uint tokens) public returns (bool success);
 function getTest() public returns (address);
 event Transfer(address indexed from, address indexed to, uint tokens);
 event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

