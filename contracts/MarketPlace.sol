pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

import "./ERC20Interface.sol";
import "./MarketPlaceInterface.sol";

contract MarketPlace is MarketPlaceInterface
{
	/*Data structures */

	struct DataSource{
		byte32 name;
		uint monthlyPrice;
		address owner;
	}
	struct DataProvider{
		address provider;
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
	// Mapping DataSource Name to DataProvider - Names must be unique
	mapping(bytes32 => DataProvider) mDataProviders;
	// Mapping Address to Subscription
	mapping(address => Subscriber) mSubscribers;

	function MarketPlace(address enigmaToken, uint pFixedSubscriptionPeriod) public 
	{
		mFixedSubscriptionPeriod = pFixedSubscriptionPeriod;
		mToken = ERC20Interface(enigmaToken);
	}
	function subscribe(bytes32 pDataSourceName) public returns (bool)
	{

		//function transfer(address to, uint tokens) public returns (bool success);
		return true;
	}
	function register(bytes32 pDataSourceName, uint pPrice, address pDataOwner) 
	public uniqueDataSourceName(pDataSourceName) returns (bool)
	{
		return true;
	}
	modifier uniqueDataSourceName(bytes32 pTestName) internal returns (bool){
		require(!mDataProviders[pTestName].isProvider)
			_;
	}
}