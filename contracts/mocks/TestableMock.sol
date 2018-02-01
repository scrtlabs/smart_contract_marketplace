pragma solidity 0.4.18;


import "../Marketplace.sol";

/*
*@title mock MarketPlace contract
*@dev unit testing 
*/

contract TestableMock is Marketplace{
    function TestableMock(address _tokenAddress) Marketplace(_tokenAddress){
        
    }
        // mock temp func
    function mockPayableProvider(bytes32 _dataSourceName, uint _price, address _dataOwner, bool isPunished)
    public returns(bool){
        // add mock provider 
        mProviders[_dataSourceName].owner = _dataOwner;
        mProviders[_dataSourceName].volume = 0;
        mProviders[_dataSourceName].subscriptionsNum = 0;
        mProviders[_dataSourceName].name = _dataSourceName;
        mProviders[_dataSourceName].price = _price;
        mProviders[_dataSourceName].isPunished = isPunished;
        mProviders[_dataSourceName].punishTimeStamp = now/2 - FIXED_SUBSCRIPTION_PERIOD/2;
        mProviders[_dataSourceName].isProvider = true;
        mProviders[_dataSourceName].isActive = true;
        mProviders[_dataSourceName].nextProvider = "";
        mProviders[mCurrent].nextProvider = _dataSourceName;
        mCurrent = mProviders[_dataSourceName].name;
        mProvidersSize = mProvidersSize.add(1);
        // add order 
            mOrders[_dataSourceName].push(Order({
            dataSourceName : _dataSourceName,
            subscriber : msg.sender,
            provider : mProviders[_dataSourceName].owner,
            price : mProviders[_dataSourceName].price,
            startTime : now/2 - FIXED_SUBSCRIPTION_PERIOD,
            endTime : now/2,
            isPaid : false,
            isOrder : true,
            isRefundPaid : false
            }));
        // update provider data 
        mProviders[_dataSourceName].volume = mProviders[_dataSourceName].volume.add(mProviders[_dataSourceName].price);
        mProviders[_dataSourceName].subscriptionsNum = mProviders[_dataSourceName].subscriptionsNum.add(1);
        return true;
    }
    // function mock_add_provider_subscriber(bytes32 _dataSourceName, uint _price, bool _isPunished, uint relativePunishtime)public 
    // uniqueDataName(_dataSourceName)
    // validPrice(_price)
    // returns (bool success){
    //     require(_dataOwner != address(0));
    //     mProviders[_dataSourceName].owner = _dataOwner;
    //     mProviders[_dataSourceName].volume = 0;
    //     mProviders[_dataSourceName].subscriptionsNum = 0;
    //     mProviders[_dataSourceName].name = _dataSourceName;
    //     mProviders[_dataSourceName].price = _price;
    //     mProviders[_dataSourceName].isPunished = _isPunished;
    //     if(isPunished){
    //     	mProviders[_dataSourceName].punishTimeStamp = 0;
    //     }else{
    //     	mProviders[_dataSourceName].punishTimeStamp = 0;
    //     }
    //     mProviders[_dataSourceName].isProvider = true;
    //     mProviders[_dataSourceName].isActive = true;
    //     mProviders[_dataSourceName].nextProvider = "";
    //     mProviders[mCurrent].nextProvider = _dataSourceName;
    //     mCurrent = mProviders[_dataSourceName].name;
    //     mProvidersSize = mProvidersSize.add(1);
    //     Registered(_dataOwner,_dataSourceName,_price,true);
    //     success =  true;
    // }
}