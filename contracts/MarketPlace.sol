pragma solidity ^0.4.18;


import "./IMarketPlace.sol";
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


contract MarketPlace is IMarketPlace
{
	using SafeMath for uint256;
	using SafeMath for uint;

	/*Data structures */
	struct Datasource{
		address signedBy;
		address owner;
		uint256 price;
		uint256 volume;
		uint256 subscriptionsNumber;
		bool isSource;
		bool isActive;
	}
	struct Subscription{
		uint256 price;
		uint startTime;
		uint endTime;
	}

	mapping(bytes32=>Datasource) mDataSources;
	mapping(address=>mapping(bytes32=>Subscription)) mSubscribers;

	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined in the C'tor (unixTimeStamp)
	uint public constant mFixedSubscriptionPeriod = 30 days;


	function MarketPlace(address _tokenAddress) public 
	{
		mToken = IERC20(_tokenAddress);
	}

	function subscribe(bytes32 _dataSourceName) 
	public 
	dataSourceAlive(_dataSourceName) 
	returns (bool)
	{
		// pay for subscription
		bool success = safeTransfer(msg.sender,mDataSources[_dataSourceName].owner,mDataSources[_dataSourceName].price);
		require(success); // LOL
		// update the dataSource
		mDataSources[_dataSourceName].volume = mDataSources[_dataSourceName].volume.add(mDataSources[_dataSourceName].price);
		mDataSources[_dataSourceName].subscriptionsNumber = mDataSources[_dataSourceName].subscriptionsNumber.add(1);
		// update the subscription info
		mSubscribers[msg.sender][_dataSourceName].price = mDataSources[_dataSourceName].price;
		mSubscribers[msg.sender][_dataSourceName].startTime = now;
		mSubscribers[msg.sender][_dataSourceName].endTime = mFixedSubscriptionPeriod.add(now);
		Subscribed(msg.sender,_dataSourceName, mDataSources[_dataSourceName].owner,mDataSources[_dataSourceName].price, true);
		return true;
	}
	function register(bytes32 _dataSourceName, uint _price, address _dataOwner) 
	public 
	validPrice(_price)
	uniqueDataSourceName(_dataSourceName) 
	returns (bool)
	{
		require(_dataOwner != address(0));
		mDataSources[_dataSourceName].signedBy = msg.sender;
		mDataSources[_dataSourceName].owner = _dataOwner;
		mDataSources[_dataSourceName].price = _price;
		mDataSources[_dataSourceName].volume = 0;
		mDataSources[_dataSourceName].subscriptionsNumber = 0;
		mDataSources[_dataSourceName].isSource = true;
		mDataSources[_dataSourceName].isActive = true;
		Registered(_dataOwner, _dataSourceName, _price, true);
		return true;
	}
	function updateDataSourcePrice(bytes32 _dataSourceName, uint256 _newPrice) 
	external
	validPrice(_newPrice) 
	onlyDataOwner(_dataSourceName,msg.sender) 
	returns (bool)
	{
		mDataSources[_dataSourceName].price = _newPrice;
		PriceUpdate(msg.sender, _dataSourceName, _newPrice);
		return true;
	} 
	function changeDataSourceActivityStatus(bytes32 _dataSourceName,bool status) 
	external
	onlyDataOwner(_dataSourceName,msg.sender) 
	returns (bool)
	{
		mDataSources[_dataSourceName].isActive = status;
		ActivityUpdate(msg.sender,_dataSourceName,status);
		return true;
	}
	function checkAddressSubscription(address _subscriber, bytes32 _dataSourceName) public view returns (address,bytes32,uint,uint,uint,bool)
	{
		require(_subscriber != address(0));
		return (_subscriber,
			_dataSourceName,
			mSubscribers[_subscriber][_dataSourceName].price,
			mSubscribers[_subscriber][_dataSourceName].startTime,
			mSubscribers[_subscriber][_dataSourceName].endTime,
			isExpiredSubscription(_subscriber,_dataSourceName));
	}

	function getOwnerFromName(bytes32 _dataSourceName) public view returns(address)
	{
		return mDataSources[_dataSourceName].owner;
	}
	function getDataSource(bytes32 _dataSourceName) public view returns(address,uint256,uint256,uint256,bool,bool)
	{
		return (mDataSources[_dataSourceName].owner,
			mDataSources[_dataSourceName].price,
			mDataSources[_dataSourceName].volume,
			mDataSources[_dataSourceName].subscriptionsNumber,
			mDataSources[_dataSourceName].isSource,
			mDataSources[_dataSourceName].isActive);
	}
	function isExpiredSubscription(address _subscriber, bytes32 _dataSourceName) public returns (bool)
	{
		return mFixedSubscriptionPeriod.add(now) >= mSubscribers[_subscriber][_dataSourceName].endTime;
	}
	function isActiveDataSource(bytes32 _dataSourceName) external returns (bool)
	{
		return mDataSources[_dataSourceName].isActive;
	}
	/*
		Internal Functions
	*/

	function safeTransfer(address _from, address _to, uint256 _amount) internal returns (bool){
		require(address(_from) != 0 && address(_to)!=0);
		require(mToken.allowance(_from,address(this)) >= _amount);
		require(mToken.transferFrom(_from,_to,_amount));
		SubscriptionPaid(_from, _to, _amount);
		return true;
	}

	/*
		Modifiers
	*/
	modifier uniqueDataSourceName(bytes32 _testName)
	{
		require(!mDataSources[_testName].isSource);
		_;
	}
	modifier validPrice(uint _testPrice)
	{
		// overflow check (2**256 - 1) + 1 = 0
		require(_testPrice>=0);
		_;
	}
	modifier dataSourceAlive(bytes32 _testName)
	{
		require(mDataSources[_testName].isSource && mDataSources[_testName].isActive);
		_;
	}
	modifier onlyDataOwner(bytes32 _dataSourceName, address _testAddress)
	{
		require(address(0) != _testAddress);
		require(mDataSources[_dataSourceName].owner == _testAddress);
		_;
	}
	// /* TO BE DELETED */
	// function getTest() public view returns (address){
	// 	return mToken.getTest();
	// }
	// function balanceOf(address who) public constant returns (uint256){
	// 	return mToken.balanceOf(who);
	// }
	// function transfer(address to, uint256 value) public returns (bool){
	// 	return mToken.transfer(to,value);
	// }
}