pragma solidity ^0.4.18;


//import "./IMarketplace.sol";
import "./zeppelin-solidity/SafeMath.sol";

contract IERC20 {
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function getTest() public view returns (address);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Marketplace{ //is IMarketplace{

	using SafeMath for uint256;
	using SafeMath for uint;

	/*Data structures */

	struct Order{
        bytes32 dataSourceName;
        address subscriber;
        address provider;
        uint price;
        uint startTime;
        uint endTime;
        bool isPaid;
    }
    struct Provider{
        bytes32 nextProvider;
        address owner;
        uint volume;
        uint subscriptionsNum;
        bytes32 name;
        uint price;
        bool isPunished;
        uint punishTimeStamp;
        bool isProvider;
    }

    // pointer to linked listen 
    bytes32 mBegin; 
    bytes32 mCurrent;
    uint size;
	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined (unixTimeStamp)
	uint public constant FIXED_SUBSCRIPTION_PERIOD = 30 days;
	// the Contract deployer
	address mMarketPlaceOwner;
    // all providers
    mapping(bytes32=>Provider) mProviders;
    mapping(bytes32=>Order[]) mOrders;
	function Marketplace(address _tokenAddress) public {
		require(_tokenAddress != address(0));
		mToken = IERC20(_tokenAddress);
		mMarketPlaceOwner = msg.sender;
        mProviders[0x0].nextProvider = "";
        mProviders[0x0].name = 0x0;
        mCurrent = mProviders[0x0].name;
        mBegin = mProviders[0x0].name;
        size = 1;
	}
    function register(bytes32 _dataSourceName, uint _price, address _dataOwner) public returns (bool){
        mProviders[_dataSourceName].price = _price;
        mProviders[_dataSourceName].owner = _dataOwner;
        mProviders[_dataSourceName].name = _dataSourceName;
        mProviders[_dataSourceName].nextProvider = "null";
        mProviders[mCurrent].nextProvider = _dataSourceName;
        mCurrent = mProviders[_dataSourceName].name;
        size += 1;
    }
    function getAllProviders() public view returns (bytes32[]){
        bytes32[] memory names = new bytes32[](size);
        bytes32 iterator = mBegin;
        for(uint i=0; i< size; ++i){
            names[i] = mProviders[iterator].name;
            iterator = mProviders[iterator].nextProvider;
        }
        return names;
    }
    /* events - move to the interface later */
    event Registered(address indexed dataOwner, bytes32 indexed dataSourceName, uint price, bool success);
	event SubscriptionPaid(address indexed from, address indexed to, uint256 value);
	event Subscribed(address indexed subscriber,bytes32 indexed dataSourceName, address indexed dataOwner, uint price, bool success);
	event PriceUpdate(address indexed editor, bytes32 indexed dataSourceName, uint256 newPrice);
	event ActivityUpdate(address indexed editor, bytes32 indexed dataSourceName, bool newStatus);
	// new events 
	// provifer got paid 
	event TransferToProvider(address indexed dataOwner, bytes32 indexed _dataSourceName, uint256 _amount);
	// provider finished withdraw process
	event ProviderWithdraw(address indexed dataOwner, bytes32 indexed _dataSourceName, uint _amount);
}