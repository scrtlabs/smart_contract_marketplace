pragma solidity ^0.4.18;

/*
*@title MarketPlace interface
*@dev This is the interface of the marketplace contract for enigma.
*/
contract IMarketplace{

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
	function register(bytes32 _dataSourceName, uint256 _price, address _dataOwner) public returns (bool success);
	/*
	*@dev change the punishment status of a provider, defaults to false (not punished)
	*@param _dataSourceName - the provider 
	*@param _isPunished - true = punish , false = not punished
	*@return bool - successful transaction 
	*/
	function setPunishProvider(bytes32 _dataSourceName, bool _isPunished) public returns (bool success);
	/*
	*@dev get the current ENG balance of the contract -> dynamiclly calculated upon request 
	*@return uint256 total balance in ENG tokens  
	*/
	function getMarketplaceTotalBalance() public view returns (uint256 totalBalance);
	/*
	*@dev get refund of the ENG tokens from the contract to the Subscriber (Punished providers)
	*@param _dataSourceName - the data source name 
	*@return success - true if happend false otherwise.
	*/
	function refundSubscriber(bytes32 _dataSourceName) public returns(bool success);
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
	*@dev get the available refund (punished providers) amount for a subscriber. (not transfering)
	*@param _susbcriber the subscriber address
	*@param _dataSourceName the name of the data provider 
	*@return refundAmount - total amount that can be refunded
	*/
	function getRefundAmount(address _subscriber , bytes32 _dataSourceName) public view returns(uint256 refundAmount);
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
	*@dev an event that indicates that someone has paid the Marketplace contract subscription (before that data is updated in the contract)
	*@param from who paid
	*@param to the data source owner
	*@param value the value that was transfered
	*/
	event SubscriptionDeposited(address indexed from, address indexed to, uint256 value);
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
	*@dev triggerd upon a token transfer to provider (before finishing state update)
	*@param dataOwner - the owner that got paid 
	*@param dataSourceName - the name of the data source
	*@param amount - the amount transferd from the marketplace contract to the provider
	*/
	event TransferToProvider(address indexed dataOwner, bytes32 indexed dataSourceName, uint256 amount);
	/*
	*@dev triggerd when the provider finished the withdraw (TransferToProvider event + state update)
	*@param dataOwner - the owner that withdrawed
	*@param dataSourceName - name of the data source
	*@param amount - the amount withdrawed
	*/
	event ProviderWithdraw(address indexed dataOwner, bytes32 indexed dataSourceName, uint amount);
    /*
	*@dev triggerd when punishment status changed (true = punished, false = not punished)
	*@param dataOwner - the provider 
	*@param dataSourceName - the name of the data source 
	*@param isPunished - the status current status AFTER the change
    */
    event ProviderPunishStatus(address indexed dataOwner, bytes32 indexed dataSourceName, bool isPunished);
	/*
	*@dev triggerd when the subscriber got a refund (punished provider)
	*@param subscriber - the refunded address
	*@param dataSourceName - name of the data source
	*@param amount - the amount of the refund
	*/
    event SubscriberRefund(address indexed subscriber,bytes32 indexed dataSourceName, uint256 refundAmount);
}