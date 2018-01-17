pragma solidity ^0.4.18;

import "./ERC20Interface.sol";
import "./MarketPlaceInterface.sol";

contract MarketPlace is MarketPlaceInterface
{
	/*Data structures */

	struct DataSource{
		bytes32 name;
		uint monthlyPrice;
		address owner;
	}
	struct DataProvider{
		address owner;
		bool isProvider;
		DataSource[] sources;
	}
	struct SubscribedDataSource{
		DataSource dataSource;
		uint startTime;
		uint endTime;
	}
	struct Subscriber{
		address subscriber;
		SubscribedDataSource[] sources;
	}
	/* State variables */

	// Enigma Token
	ERC20Interface public mToken;
	// Fixed time defined in the C'tor (unixTimeStamp)
	uint private mFixedSubscriptionPeriod;
	// Mapping addres owner to DataProvider - Names must be unique
	mapping(address => DataProvider) mDataProviders;
	// Mapping Address to Subscription
	mapping(address => Subscriber) mSubscribers;
	// Names map - works like a hashshet.
	mapping(bytes32 => address) mNameMap;

	function MarketPlace(address _enigmaToken, uint _fixedSubscriptionPeriod) public 
	{
		mFixedSubscriptionPeriod = _fixedSubscriptionPeriod;
		mToken = ERC20Interface(_enigmaToken);
	}

	function subscribe(bytes32 _dataSourceName) public returns (bool)
	{

		//function transfer(address to, uint tokens) public returns (bool success);
		return true;
	}
	function register(bytes32 _dataSourceName, uint _price, address _dataOwner) 
	public 
	uniqueDataSourceName(_dataSourceName) 
	returns (bool)
	{
		require(_dataOwner != address(0));
		mNameMap[_dataSourceName] = _dataOwner;	
		if(isNewProvider(_dataOwner)) // New Provider (Address identifier)
		{
			// create a data provider 
			DataProvider dp;
			dp.owner = _dataOwner;
			dp.isProvider = true;
			dp.sources.push(DataSource({name:_dataSourceName,
									  monthlyPrice:_price,
									  owner:_dataOwner}));
			mDataProviders[_dataOwner] = dp;
		}
		else // Existing Provider (New DataSource)
		{
			mDataProviders[_dataOwner].sources.push(DataSource({
				name:_dataSourceName,
				monthlyPrice:_price,
				owner:_dataOwner
			}));
		}
		return true;
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
	/* TO BE DELETED */
	function getTest() public view returns (address){
		return mToken.getTest();
	}
}