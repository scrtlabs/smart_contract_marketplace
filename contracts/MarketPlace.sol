pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

import "./ERC20Interface.sol";
import "./MarketPlaceInterface.sol";
import "./TimeLimited";
contract MarketPlace is MarketPlaceInterface
{
	struct DataSource{
		byte32 name;
		uint monthlyPrice;
		address owner;
	}
	struct DataProvider{
		address provider;
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
	ERC20Interface public mToken;
	uint mFixedSubscriptionPeriod;

	function MarketPlace(address enigmaToken, uint pFixedSubscriptionPeriod) public 
	{
		mFixedSubscriptionPeriod = pFixedSubscriptionPeriod;
		mToken = ERC20Interface(enigmaToken);
	}
	function subscribe(bytes32 pDataSourceName) public returns (bool)
	{
		return true;
	}
	function register(bytes32 pDataSourceName, uint pPrice, address pDataOwner) public returns (bool)
	{
		return true;
	}
}