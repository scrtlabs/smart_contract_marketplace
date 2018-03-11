pragma solidity ^0.4.21;

import "./Marketplace.sol";
import "./IRecoverableMarketplace.sol";

contract RecoverableMarketplace is IRecoverableMarketplace, Marketplace{
	bytes32[] public mNames;
    function RecoverableMarketplace(address _tokenAddress) Marketplace(_tokenAddress) public {}
	/* Subscriptions */
    function refundSubscriberAt(bytes32 _dataSourceName, uint256 _index)
    public 
    isValidIndex(_dataSourceName,_index)
    onlySubscriber(_dataSourceName,_index)
    returns
    (bool success){
        require(mProviders[_dataSourceName].isProvider);
        uint256 refundAmount = 0;
        refundAmount = handleOrderRefundCalc(mOrders[_dataSourceName][_index]);
        require(refundAmount > 0);
        require(!mOrders[_dataSourceName][_index].isRefundPaid); // double check refund
        mOrders[_dataSourceName][_index].isRefundPaid = true;// mark refund as paid
        // transfer ENG to subscriber - revert if failed
        require(safeToSubscriberTransfer(msg.sender,refundAmount));
        emit SubscriberRefund(msg.sender,_dataSourceName,refundAmount);
        success = true;
    }
    function getRefundAmountAt(bytes32 _dataSourceName,uint256 _index) 
    public 
    view 
    returns(uint256 refundAmount){
        require(mProviders[_dataSourceName].isProvider);
        refundAmount = 0;
        if(0 <= _index && _index <= mOrders[_dataSourceName].length){
            refundAmount = handleOrderRefundCalc(mOrders[_dataSourceName][_index]);
        }
    }
	function getSubscriptionsSize(bytes32 _dataSourceName) public view returns (uint256 size){
		size = mOrders[_dataSourceName].length;
	}
	function checkSubscriptionAt(bytes32 _dataSourceName, uint256 _index) 
    public 
    view 
    returns 
    (   address subscriber,
        bytes32 dataSourceName,
        uint price,
        uint startTime,
        uint endTime,
        bool isUnExpired,
        bool isPaid, 
        bool isPunishedProvider,
        bool isOrder){
        if(0 <= _index && _index <= mOrders[_dataSourceName].length){
            subscriber = mOrders[_dataSourceName][_index].subscriber;
            dataSourceName = mOrders[_dataSourceName][_index].dataSourceName;
            price = mOrders[_dataSourceName][_index].price;
            startTime = mOrders[_dataSourceName][_index].startTime;
            endTime = mOrders[_dataSourceName][_index].endTime;
            isUnExpired = !isOrderExpired(mOrders[_dataSourceName][_index]);
            isPaid = mOrders[_dataSourceName][_index].isPaid;
            isPunishedProvider = mProviders[_dataSourceName].isPunished;
            isOrder = mOrders[_dataSourceName][_index].isOrder;
        }
	}
    function isExpiredSubscriptionAt(bytes32 _dataSourceName,uint256 _index) 
    public 
    view 
    returns(bool isExpired) {
        if(0 <= _index && _index <= mOrders[_dataSourceName].length){
            isExpired = (now >= mOrders[_dataSourceName][_index].endTime);
        }
    }
	/* Data providers */

    function register(bytes32 _dataSourceName, uint256 _price, address _dataOwner) 
    public
    uniqueDataName(_dataSourceName)
    validPrice(_price)
    returns (bool success){
        require(super.register(_dataSourceName,_price,_dataOwner));
        mNames.push(_dataSourceName);
        success = true;
    }
    function withrawProviderAt(bytes32 _dataSourceName, uint256 _index) 
    public 
    isValidIndex(_dataSourceName, _index)
    onlyDataProvider(_dataSourceName) 
    returns(bool success){
        uint256 withdrawAmount = 0;
        withdrawAmount = handleOrderWithdrawCalc(mOrders[_dataSourceName][_index]);
        require(withdrawAmount > 0);
        require(!mOrders[_dataSourceName][_index].isPaid);//double check payment
        mOrders[_dataSourceName][_index].isPaid = true;
        // transfer ENG's to the provider -revert state if faild
        require(safeToProviderTransfer(_dataSourceName,withdrawAmount)); 
        emit ProviderWithdraw(mProviders[_dataSourceName].owner,_dataSourceName,withdrawAmount);
        success = true;
    }
    function getWithdrawAmountAt(bytes32 _dataSourceName, uint256 _index) 
    public 
    view 
    returns (uint256 withdrawAmount){
        require(mProviders[_dataSourceName].isProvider);
        if(0 <= _index && _index <= mOrders[_dataSourceName].length){
            withdrawAmount = handleOrderWithdrawCalc(mOrders[_dataSourceName][_index]);
        }
    }
	function getProviderNamesSize() public view returns(uint256 size){
		size = mNames.length;
	}
	function getNameAt(uint256 _index) public view returns(bytes32 _dataSourceName){
		if(0 <= _index  && _index <= mNames.length){
			_dataSourceName = mNames[_index];
		}
	}
    /* modifiers */
    modifier onlySubscriber(bytes32 _dataSourceName, uint256 _index){
        require(mOrders[_dataSourceName][_index].subscriber == msg.sender);
        _;
    }
    modifier isValidIndex(bytes32 _dataSourceName, uint256 _index){
        require(0 <= _index && _index <= mOrders[_dataSourceName].length);
        _;
    }

}
