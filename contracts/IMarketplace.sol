pragma solidity ^0.4.18;

/*
*@title MarketPlace interface
*@dev This is the interface of the marketplace contract for enigma.
*/
contract IMarketplace{
	/*
	*@dev if data set owner wants to update the price for FUTURE users.
	*@param _dataSourceName name of the data source
	*@param _newPrice the new price
	*@return true if updated;
	*/
	function updateDataSourcePrice(bytes32 _dataSourceName, uint256 _newPrice) external returns (bool success);
	/*
	*@dev the ability to turn off/on a data set for FUTURE sales. Default on subscriotion is TRUE.
	*@param _datasourceName the name of the data source.
	*@param _isActive true = sellable , false = not sellable 
	*@return true if success.
	*/
	function changeDataSourceActivityStatus(bytes32 _dataSourceName,bool _isActive) external returns (bool success);
	/*
	*@dev data providers can decide to turn off/on their offer for future requests.
	*@param _dataSourceName the data source in context
	*@return bool true if Active (the data source is for sale). false otherwise (data source not for sale)
	*/
	function isActiveDataSource(bytes32 _dataSourceName) external view returns (bool isActive);
	/*
	*@dev used by users who would like to use and pay a data provider. 
	*@param _dataSourceName chosen data source name.
	*@return bool true of successful. 
	*/
	function subscribe(bytes32 _dataSourceName) public returns (bool success);
	/*
	*@dev for data providers to list their data set. 
	*@param _dataSourceName the unique name that will be used for listing the data set
	*@param _price the subscription price 
	*@paran _dataOwner the account that will get paid and owns the data.
	*@return true if success.
	*/
	function register(bytes32 _dataSourceName, uint _price, address _dataOwner) public returns (bool success);
	/*
	*@dev change the punishment status of a provider, defaults to false (not punished)
	*@param _dataSourceName - the provider 
	*@param _isPunished - true = punish , false = not punished
	*@return bool - successful transaction 
	*/
	function setPunishProvider(bytes32 _dataSourceName, bool _isPunished) public returns (bool success);
	/*
	*@dev check the status of some subscriber, time is taken based on block.timestamp (UNIX)
	*@param _subscriber the subscriber address
	*@param _dataSourceName the name of the data source to check against
	*@return address - the subscriber address (double verification)
	*@return bytes32 - the data set name (double verification)
	*@return uint - subscription price
	*@return uint - subscription start time
	*@return uint - subscription end time
	*@return bool - is subscription expired, true = expired, false = not expired
	*@return bool - isPaid , did the subscriber pay already for the subscription (to the Data provider) 
    *@return bool - isPunishedProvider , is the provider of the subscription punished
    *@return bool - isOrder , true if the order exists, false otherwise
	*/
	function checkAddressSubscription(address _subscriber, bytes32 _dataSourceName) public view returns (address subscriber,
        bytes32 dataSourceName,
        uint price,
        uint startTime,
        uint endTime,
        bool isExpired,
        bool isPaid, 
        bool isPunishedProvider,
        bool isOrder);
	/*
	*@dev get the address of the owner given a data source name. 
	*@param _dataSourceName the name of the data source
	*@return address the owner address
	*/
	function getOwnerFromName(bytes32 _dataSourceName) public view returns(address);
	/*
	*@dev get information regarding some data source given a name.
	*@param _dataSourceName the data source name
	*@return address owner - data source owner
	*@return uint256 price - the current price of the data set 
	*@return uint256 volume - the total sum of the tokens paid since registration.
	*@return uint256 - total counter of the subscriptions number to that data source
	*@return bool isProvider - should always be true if registry exists
	*@return bool isActive - true = selling, false = not selling (not active)
	*@return bool isPunished - true if punished false otherwise
	*/
	function getDataProviderInfo(bytes32 _dataSourceName) public view returns(
		address owner,
		uint256 price,
		uint256 volume,
		uint256 subscriptionsNum,
		bool isProvider,
		bool isActive,
		bool isPunished);
	/*
	@dev verify that a subscriber can access data source
	@param _subscriber the subscriber to check
	@param _dataSourceName the data source being checked 
	@return bool true if expired, false otherwise
	*/
	function isExpiredSubscription(address _subscriber, bytes32 _dataSourceName) public view returns (bool isExpired);
	/*
	*@dev get the current ENG balance of the contract -> dynamiclly calculated upon request 
	*@return uint256 total balance in ENG tokens  
	*/
	function getMarketplaceCurrentBalance() public view returns (uint256 totalBalance);
	/*
	*@dev withdraw the ENG tokens from the contract to the Provider. a transaction is made.
	*transfering to the owner registred wallet. can be activated only with the owners wallet.
	*@param _dataSourceName - the name of the data source 
	*@return bool success - true if transferd false otherwise
	*/
	function withdrawProvider(bytes32 _dataSourceName) public returns (bool success);
	/*
	@dev get the withdraw amount of a provider (not transfering)
	@param _dataSourceName - the name of the data source 
	@return withdrawAmount - total amount that can be withdrawed
	*/
	function getWithdrawAmount(bytes32 _dataSourceName) public view returns(uint256 withdrawAmount);
	/*
	*@dev 
	*/
	function getRefundAmount(address _susbcriber , bytes32 _dataSourceName) public view returns(uint256 refundAmount);
	/*********** Events ************/
	
	/*
	*@dev When data provider finishes registration in the contract
	*@param dataOwner the owner of the data
	*@param dataSourceName the new name registred
	*@param price the price for subscription
	*@param true if registred successfully
	*/
	event Registered(address indexed dataOwner, bytes32 indexed dataSourceName, uint price, bool success);
	/*
	*@dev an event that indicates that someone has paid during subscription (before that data is updated in the contract)
	*@param from who paid
	*@param to the data source owner
	*@param value the value that was transfered
	*/
	event SubscriptionPaid(address indexed from, address indexed to, uint256 value);
	/*
	*@dev an event fired every time subscription has finished (AFTER succssfull payment AND data update).
	*@param subscriber who subscribed
	*@param dataSourceName the data source name
	*@param dataOwner the owner of the data source
	*@param price the price paid for subscription
	*@param success true if subscribed successfully
	*/
	event Subscribed(address indexed subscriber,bytes32 indexed dataSourceName, address indexed dataOwner, uint price, bool success);
	/*
	*@dev triggerd uppon a price change of an existing data source
	@param editor the owner that changed the price
	@param dataSourceName the data source that has changed
	@param newPrice the new price.
	*/
	event PriceUpdate(address indexed editor, bytes32 indexed dataSourceName, uint256 newPrice);
	/*
	*@dev triggerd upon a change in the state of a data source availablity.
	@param editor who changed the activity state
	@param dataSourceName which dataSource changed. 
	@param newStatus true = active, false = not active (cannot be sold)
	*/
	event ActivityUpdate(address indexed editor, bytes32 indexed dataSourceName, bool newStatus);
}