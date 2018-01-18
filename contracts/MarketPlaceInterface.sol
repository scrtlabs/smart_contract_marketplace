pragma solidity ^0.4.18;

contract MarketPlaceInterface 
{
	function subscribe(bytes32 _dataSourceName) public returns (bool);
	function register(bytes32 _dataSourceName, uint _price, address _dataOwner) public returns (bool);
	function checkAddressSubscription(address _subscriber, bytes32 _dataSourceName) public returns (bool);
	
	event Subscribed(address subscriber,bytes32 dataSourceName, address dataOwner, uint price, bool success);
	event Registered(address dataOwner, bytes32 dataSourceName, uint price, bool success);
}