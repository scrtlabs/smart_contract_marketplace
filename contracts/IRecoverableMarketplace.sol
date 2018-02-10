pragma solidity 0.4.18;

/*
*@title MarketPlace  Recovery interface
*@dev Enigma Marketplace
*/
contract IRecoverableMarketplace{

	/* Subscriptions */
    function refundSubscriberAt(bytes32 _dataSourceName, uint256 _index)public returns(bool success);
    function getRefundAmountAt(bytes32 _dataSourceName,uint256 _index) public view returns(uint256 refundAmount);
	function getSubscriptionsSize(bytes32 _dataSourceName) public view returns (uint256 size);
	function checkSubscriptionAt(bytes32 _dataSourceName, uint256 _index) public view returns 
    (   address subscriber,
        bytes32 dataSourceName,
        uint price,
        uint startTime,
        uint endTime,
        bool isUnExpired,
        bool isPaid, 
        bool isPunishedProvider,
        bool isOrder);
    function isExpiredSubscriptionAt(bytes32 _dataSourceName,uint256 _index) public view returns(bool isExpired);
	/* Data providers */
    function register(bytes32 _dataSourceName, uint256 _price, address _dataOwner) public returns (bool success);
    function withrawProviderAt(bytes32 _dataSourceName, uint256 _index) public returns(bool success);
    function getWithdrawAmountAt(bytes32 _dataSourceName, uint256 _index) public view returns (uint256 withdrawAmount);
	function getProviderNamesSize() public view returns(uint256 size);
	function getNameAt(uint256 _index) public view returns(bytes32 _dataSourceName);
}