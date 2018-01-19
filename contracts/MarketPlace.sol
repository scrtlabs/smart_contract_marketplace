pragma solidity ^0.4.18;


import "./MarketPlaceInterface.sol";


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
// contract ERC20 {
//   uint256 public totalSupply;
//   function balanceOf(address who) public constant returns (uint256);
//   function transfer(address to, uint256 value) public returns (bool);
//   function getTest() public view returns (address);
//   event Transfer(address indexed from, address indexed to, uint256 value);
// }


contract MarketPlace is MarketPlaceInterface
{
	/*Data structures */

	/* A provider can have many DataSource's*/
	struct DataSource{
		bytes32 name;
		uint monthlyPrice;
		address owner;
		bool isData;
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
		bool isSubscriber;
		SubscribedDataSource[] sourcesList;
		mapping(bytes32=>SubscribedDataSource) sourcesMap;
	}
	/* State variables */
	
	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined in the C'tor (unixTimeStamp)
	uint public mFixedSubscriptionPeriod;
	// Mapping addres owner to DataProvider - Names must be unique
	mapping(address => DataProvider) mDataProviders;
	// Mapping Address to Subscription
	mapping(address => Subscriber) mSubscribers;
	// Names map - works like a hashshet.
	mapping(bytes32 => address) mNameMap;

	function MarketPlace(address _tokenAddress, uint _fixedSubscriptionPeriod) public 
	{
		mFixedSubscriptionPeriod = _fixedSubscriptionPeriod;
		mToken = IERC20(_tokenAddress);
	}

	function subscribe(bytes32 _dataSourceName) 
	public 
	dataSourceNameExist(_dataSourceName) 
	returns (bool)
	{
		string memory testData = "Enterd function subscribe";
		TestLog(msg.sender,msg.sender, testData);
		// pay and verify
		address providerAddress = mNameMap[_dataSourceName];
		require(!isNewProvider(providerAddress));
		DataSource ds = mDataProviders[providerAddress].sourcesMap[_dataSourceName];
		require(ds.isData);
		SubscribedDataSource storage sds;
		require(mToken.transfer(providerAddress,ds.monthlyPrice));
		
		// update subscription details
		sds.dataSource = ds;
		sds.startTime = now; 
		sds.endTime = now + mFixedSubscriptionPeriod;

		if(isNewSubscriber(msg.sender))
		{
			Subscriber subscriber;
			subscriber.subscriber = msg.sender;
			subscriber.isSubscriber = true;
			subscriber.sourcesList.push(sds);
			subscriber.sourcesMap[_dataSourceName] = sds;		
			mSubscribers[msg.sender] = subscriber;
		}
		else
		{
			mSubscribers[msg.sender].sourcesList.push(sds);
			mSubscribers[msg.sender].sourcesMap[_dataSourceName] = sds;
		}
		Subscribed(msg.sender,_dataSourceName, providerAddress, ds.monthlyPrice, true);
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
		ds.isData = true;

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

	function checkAddressSubscription(address _subscriber, bytes32 _dataSourceName) public returns (bool)
	{
		require(_subscriber != address(0));
		return true;
	}

	function getOwnerAddressByDataSourceName(bytes32 _dataSourceName) public view returns(address){
		return mNameMap[_dataSourceName];
	}
	/*
		Internal Functions
	*/
	function isNewProvider(address _testProvider) internal view returns (bool)
	{
		if(mDataProviders[_testProvider].isProvider)
			return false;
		else
			return true;
	}
	function isNewSubscriber(address _testSubscriber) internal view returns (bool)
	{
		if(mSubscribers[_testSubscriber].isSubscriber)
			return false;
		else
			return true;
	}
	/*
		Modifiers
	*/
	modifier uniqueDataSourceName(bytes32 _testName)
	{
		require(mNameMap[_testName]==0);
		_;
	}
	modifier validPrice(uint _testPrice)
	{
		require(_testPrice>=0);
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
	function balanceOf(address who) public constant returns (uint256){
		return mToken.balanceOf(who);
	}
	function transfer(address to, uint256 value) public returns (bool){
		return mToken.transfer(to,value);
	}
	function atomicTransfer(address _from, address _to, uint256 _amount) public returns (bool){
		require(address(_from) != 0 && address(_to)!=0);
		require(mToken.allowance(_from,address(this)) >= _amount);
		require(mToken.transferFrom(_from,_to,_amount));
		SubscriptionPaid(_from, _to, _amount);
		return true;
	}
}