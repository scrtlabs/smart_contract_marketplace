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

 mapping(address => uint256) balances;
 mapping(address => mapping (address => uint256)) allowed;

 function DummyToken() public
 {
 	owner = msg.sender;
 	balances[owner] = total_supply;
 }
 function totalSupply() public constant returns (uint)
 {
 	return total_supply;
 }
 function balanceOf(address tokenOwner) public constant returns (uint balance)
 {
 	return balances[tokenOwner];
 }
 function transfer(address to, uint tokens) public returns (bool success)
 {
 	require(balances[msg.sender] >= tokens);
 	balances[msg.sender] -= tokens;
 	balances[to] += tokens;
 	Transfer(msg.sender, to, tokens);
 	return true;
 }

 function transferFrom(address from, address to, uint tokens) public returns (bool success){return true;}
 function approve(address spender, uint tokens) public returns (bool success){return true;}
 function allowance(address tokenOwner, address spender) public constant returns (uint remaining){return 0;}
}