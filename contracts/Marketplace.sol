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
        address owner;
        uint volume;
        uint subscriptionsNum;
        bytes32 name;
        uint price;
        bool isPunished;
        uint punishTime;
        bool isProvider;
    }

	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined (unixTimeStamp)
	uint public constant FIXED_SUBSCRIPTION_PERIOD = 30 days;
	// the Contract deployer
	address mMarketPlaceOwner;
    // contracts total balance
    uint256 public mTotalBalance;
    // all open/closed orders
    Order [] mOrders;
    // all providers
    mapping(bytes32 => Provider) mProviders;

	function Marketplace(address _tokenAddress) public {
		require(_tokenAddress != address(0));
		mToken = IERC20(_tokenAddress);
		mMarketPlaceOwner = msg.sender;
	}
	/* data subscription logic */
	function subscribe(bytes32 _dataSourceName) 
	external 
	providerExist(_dataSourceName)
	providerNotPunished(_dataSourceName) 
	returns(bool){
		bool success = safeToMarketTransfer(msg.sender,this,mProviders[_dataSourceName]);
		require(success);
		mOrders.push(Order({
			dataSourceName : _dataSourceName,
			subscriber : msg.sender,
			provider : mProviders[_dataSourceName].owner,
			price : mProviders[_dataSourceName].price,
			startTime : now,
			endTime : now + FIXED_SUBSCRIPTION_PERIOD,
			isPaid : true
			}));
		return true;
	}
	/* name registration logic */
	function register(bytes32 _dataSourceName, uint _price, address _dataOwner) 
	external 
	uniqueName(_dataSourceName) 
	returns(bool){
		require(_dataOwner != address(0));
		require(_price.add(1) > _price); // overflow check (2**256 - 1) + 1 = 0 inside SafeMath
		mProviders[_dataSourceName].owner = _dataOwner;
		mProviders[_dataSourceName].volume = mProviders[_dataSourceName].volume.add(_price);
		mProviders[_dataSourceName].subscriptionsNum =mProviders[_dataSourceName].subscriptionsNum.add(1);
		mProviders[_dataSourceName].name = _dataSourceName;
		mProviders[_dataSourceName].price = _price;
		mProviders[_dataSourceName].isPunished = false;
		mProviders[_dataSourceName].punishTime = 0;
		mProviders[_dataSourceName].isProvider = true;
		return true;
	}
    /* penallty,punishment logic */
    function setPenalty(bytes32 _dataSourceName, bool _isPunished) 
    external 
    ownerOnly 
    providerExist(_dataSourceName) 
    returns(bool){
        mProviders[_dataSourceName].isPunished = _isPunished;
        mProviders[_dataSourceName].punishTime = now;
        return true;
    }
    /* subscriber refund logic */
    
    function getRefundAmount(address _subscriber) 
    external 
    view 
    returns (uint256 available){
        uint accumulated;
        for(uint i=0; i<mOrders.length;i++){
            Order storage order = mOrders[i];
            Provider storage provider = mProviders[order.dataSourceName];
            if(order.subscriber == _subscriber && !order.isPaid){ // not paid yet
                if(isPunished(provider.name)){ // provider punished
                    if(provider.punishTime < order.endTime){ //provider punished before subscription expired 
                        accumulated += calcRelativeRefund(order,provider);
                    }
                }
            }
        }
        return accumulated;
    }

    /* provider withdraw logic */
    function getWithdrawAmount(bytes32 _dataSourceName) external view returns (uint256 available){
        uint256  accumulated;
        for(uint i=0; i<mOrders.length; i++){
            Order storage order = mOrders[i];
            Provider storage provider = mProviders[order.dataSourceName];
            if(order.dataSourceName == _dataSourceName && order.dataSourceName == provider.name){
                accumulated += handleGetWithdraw(order,provider);   
            }
        }
        return accumulated;
    }


    function isPunished(bytes32 _dataSourceName) public view returns(bool){
        return mProviders[_dataSourceName].isPunished;
    }

    /* internal functions */

    // work on that + events declaration 
	function safeToMarketTransfer(address _from, address _to, uint256 _amount) internal returns (bool){
		require(address(_from) != 0 && address(_to)!=0);
		require(mToken.allowance(_from,address(this)) >= _amount);
		require(mToken.transferFrom(_from,_to,_amount));
		SubscriptionPaid(_from, _to, _amount);
		return true;
	}
	// is subcription expired
	function isExpired(Order _order) internal view returns (bool){
        return now > _order.startTime + FIXED_SUBSCRIPTION_PERIOD; 
    }
	// relative amount to withdraw from a punished provider
	function calcRelativeWithdraw(Order _order,Provider _provider) internal view returns (uint256 amount){
        if(_provider.punishTime > _order.endTime){
            return _order.price;   
        }
        return (_provider.punishTime / _order.endTime) * _order.price;
    }
    // withdraw relaed => handle an instance provider calculation
    function handleGetWithdraw(Order _order, Provider _provider) private view returns(uint256 amount){
        if(_order.dataSourceName == _provider.name && !_order.isPaid){
                if(isExpired(_order)){
                    if(isPunished(_provider.name)){
                        return calcRelativeWithdraw(_order,_provider);
                    }else{
                        return _order.price;
                    }
                }
            }
            return 0;
    }
    // subscriber related => relative refund of an order instance
    function calcRelativeRefund(Order _order, Provider _provider) internal view returns(uint256 amount){
        return (1 - _provider.punishTime/ _order.endTime)  * _provider.price;
    }
    /* modifiers*/
    modifier ownerOnly(){
        require(msg.sender == mMarketPlaceOwner);
        _;
    }
    modifier providerExist(bytes32 _dataSourceName){
        require(mProviders[_dataSourceName].isProvider);
        _;
    }
    modifier uniqueName(bytes32 _dataSourceName){
    	require(!mProviders[_dataSourceName].isProvider);
    	_;
    }
    modifier providerNotPunished(bytes32 _dataSourceName){
    	require(!mProviders[_dataSourceName].isPunished);
    	_;
    }
}