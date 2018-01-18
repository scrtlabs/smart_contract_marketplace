pragma solidity ^0.4.18;


import "./MarketPlaceInterface.sol";

contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function getTest() public view returns (address);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract MarketPlace is MarketPlaceInterface
{
	/*Data structures */

	/* A provider can have many DataSource's*/
	struct DataSource{
		bytes32 name;
		uint monthlyPrice;
		address owner;
	}
	/* A Provider is unique per address*/
	struct DataProvider{
		address owner;
		bool isProvider;
		DataSource[] sourcesList;
		mapping(bytes32=>DataSource) sourcesMap;
	}
	/* A Subscriber can have many SubscribedDataSource's*/
	struct SubscribedDataSource{
		DataSource dataSource;
		uint startTime;
		uint endTime;
	}
	/* Subscriber is Unique per address*/
	struct Subscriber{
		address subscriber;
		SubscribedDataSource[] sources;
	}
	/* State variables */
	
	// Enigma Token
	ERC20 public mToken;
	// Fixed time defined in the C'tor (unixTimeStamp)
	uint private mFixedSubscriptionPeriod;
	// Mapping addres owner to DataProvider - Names must be unique
	mapping(address => DataProvider) mDataProviders;
	// Mapping Address to Subscription
	mapping(address => Subscriber) mSubscribers;
	// Names map - works like a hashshet.
	mapping(bytes32 => address) mNameMap;

	function MarketPlace(address _tokenAddress, uint _fixedSubscriptionPeriod) public 
	{
		mFixedSubscriptionPeriod = _fixedSubscriptionPeriod;
		mToken = ERC20(_tokenAddress);
	}

	function subscribe(bytes32 _dataSourceName) 
	public 
	dataSourceNameExist(_dataSourceName) 
	returns (bool)
	{
		address providerAddress = mNameMap[_dataSourceName];
		if(!isNewProvider(providerAddress))
		{
			return true;//TODO::
		}
		//function transfer(address to, uint tokens) public returns (bool success);
		return true;
	}
	function register(bytes32 _dataSourceName, uint _price, address _dataOwner) 
	public 
	validPrice(_price)
	uniqueDataSourceName(_dataSourceName) 
	returns (bool)
	{
		require(_dataOwner != address(0));

		// create a data source
		mNameMap[_dataSourceName] = _dataOwner;	
		DataSource storage ds;
		ds.name = _dataSourceName;
		ds.monthlyPrice = _price;
		ds.owner = _dataOwner;

		if(isNewProvider(_dataOwner)) // New Provider (Address identifier)
		{
			// create a data provider 
			DataProvider storage dp;
			dp.owner = _dataOwner;
			dp.isProvider = true;
			dp.sourcesList.push(ds);
			dp.sourcesMap[_dataSourceName] = ds;
			mDataProviders[_dataOwner] = dp;
		}
		else // Existing Provider (New DataSource)
		{
			mDataProviders[_dataOwner].sourcesList.push(ds);
			mDataProviders[_dataOwner].sourcesMap[_dataSourceName] = ds;
		}
		Registered(_dataOwner, _dataSourceName, _price, true);
		return true;
	}
	function getOwnerAddressByDataSourceName(bytes32 _dataSourceName) public view returns(address){
		return mNameMap[_dataSourceName];
	}
	function checkAddressSubscription(address _subscriber, bytes32 _dataSourceName) public returns (bool)
	{
		require(_subscriber != address(0));
		return true;
	}
	function isNewProvider(address _testProvider) internal view returns (bool)
	{
		if(mDataProviders[_testProvider].isProvider)
			return false;
		else
			return true;
	}
	modifier uniqueDataSourceName(bytes32 _testName)
	{
		require(mNameMap[_testName]==0);
		_;
	}
	modifier validPrice(uint _testPrice)
	{
		require(testPrice>=0);
		_;
	}
	modifier dataSourceNameExist(bytes32 _testName)
	{
		require(mNameMap[_testName] != 0);
		_;
	}
	/* TO BE DELETED */
	function getTest() public view returns (address){
		return mToken.getTest();
	}
}