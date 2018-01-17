pragma solidity ^0.4.18;

contract MarketPlaceInterface 
{
	/*
	
	*/
	function subscribe(bytes32 pDataSourceName) public returns (bool);
	function register(bytes32 pDataSourceName, uint pPrice, address pDataOwner) public returns (bool);
	function checkAddressSubscription(address pSubscriber, bytes32 pDataSourceName) public returns (bool);
	event Subscribed(address subscriber,bytes32 dataSourceName, address dataOwner, uint price);
	event Registered(address dataOwner, bytes32 dataSourceName, uint price);
}