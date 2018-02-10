pragma solidity 0.4.18;


import "./IMarketplace.sol";
import "./BasicMarketplace.sol";

/*
*@title MarketPlace contract
*@dev This is the Marketplace contract. extending BasicMarketplace.
*/

contract Marketplace is IMarketplace,BasicMarketplace{

	function Marketplace(address _tokenAddress) BasicMarketplace(_tokenAddress) public {}

    /* public*/
    
    function setPunishProvider(bytes32 _dataSourceName, bool _isPunished) 
    public 
    onlyOwner 
    returns (bool success){
        require(mProviders[_dataSourceName].isProvider);
        mProviders[_dataSourceName].isPunished = _isPunished;
        if(_isPunished){
            mProviders[_dataSourceName].punishTimeStamp = now;
        }else{
            mProviders[_dataSourceName].punishTimeStamp = 0;
        }
        ProviderPunishStatus(mProviders[_dataSourceName].owner,_dataSourceName,_isPunished);
        success = true;
    }

    function refundSubscriber(bytes32 _dataSourceName) 
    public 
    returns
    (bool success){
        require(mProviders[_dataSourceName].isProvider);
        uint256 refundAmount = 0;
        uint size = mOrders[_dataSourceName].length;
        for(uint i=0; i<size ;i++){
            if(mOrders[_dataSourceName][i].subscriber == msg.sender){
                uint256 refund = handleOrderRefundCalc(mOrders[_dataSourceName][i]);
                if(refund > 0 && !mOrders[_dataSourceName][i].isRefundPaid){ // double check payment
                    mOrders[_dataSourceName][i].isRefundPaid = true;// mark refund as paid
                    refundAmount = refundAmount.add(refund);
                }
            }
        }
        require(safeToSubscriberTransfer(msg.sender,refundAmount));
        SubscriberRefund(msg.sender,_dataSourceName,refundAmount);
        success = true;
    }
    function getRefundAmount(address _subscriber , bytes32 _dataSourceName) 
    public 
    view 
    returns(uint256 refundAmount){
        require(_subscriber != address(0));
        require(mProviders[_dataSourceName].isProvider);
        refundAmount = 0;
        uint size = mOrders[_dataSourceName].length;
        for(uint i=0; i< size ; i++){
            if(mOrders[_dataSourceName][i].subscriber == _subscriber){
                refundAmount = refundAmount.add(handleOrderRefundCalc(mOrders[_dataSourceName][i]));
            }
        }
        return refundAmount;
    }

    function withdrawProvider(bytes32 _dataSourceName) 
    public 
    onlyDataProvider(_dataSourceName) 
    returns (bool success){
        // calculate the withdraw amount 
        uint256 withdrawAmount = 0;
        uint orderSize = mOrders[_dataSourceName].length;
        for(uint i=0;i<orderSize;i++){
            uint256 withdraw = handleOrderWithdrawCalc(mOrders[_dataSourceName][i]);
            if(withdraw > 0 && !mOrders[_dataSourceName][i].isPaid){ // double check
                mOrders[_dataSourceName][i].isPaid = true; // mark order as paid 
                withdrawAmount = withdrawAmount.add(withdraw); 
            }
            
        }
        // transfer ENG's to the provider -revert state if faild
        require(safeToProviderTransfer(_dataSourceName,withdrawAmount)); 
        ProviderWithdraw(mProviders[_dataSourceName].owner,_dataSourceName,withdrawAmount);
        return true;
    }
    function getWithdrawAmount(bytes32 _dataSourceName) 
    public 
    view 
    returns(uint256 withdrawAmount){
        require(mProviders[_dataSourceName].isProvider);
        withdrawAmount = 0;
        uint orderSize = mOrders[_dataSourceName].length;
        for(uint i=0;i<orderSize;i++){
            withdrawAmount = withdrawAmount.add(handleOrderWithdrawCalc(mOrders[_dataSourceName][i])); 
        }
        return withdrawAmount;
    }

    function register(bytes32 _dataSourceName, uint256 _price, address _dataOwner) 
    public
    uniqueDataName(_dataSourceName)
    validPrice(_price)
    returns (bool success){
        require(_dataOwner != address(0));
        mProviders[_dataSourceName].owner = _dataOwner;
        mProviders[_dataSourceName].volume = 0;
        mProviders[_dataSourceName].subscriptionsNum = 0;
        mProviders[_dataSourceName].name = _dataSourceName;
        mProviders[_dataSourceName].price = _price;
        mProviders[_dataSourceName].isPunished = false;
        mProviders[_dataSourceName].punishTimeStamp = 0;
        mProviders[_dataSourceName].isProvider = true;
        mProviders[_dataSourceName].isActive = true;
        mProviders[_dataSourceName].nextProvider = "";
        mProviders[mCurrent].nextProvider = _dataSourceName;
        mCurrent = mProviders[_dataSourceName].name;
        mProvidersSize = mProvidersSize.add(1);
        Registered(_dataOwner,_dataSourceName,_price,true);
        success =  true;
    }
    function subscribe(bytes32 _dataSourceName) 
    public 
    validDataProvider(_dataSourceName)
    returns (bool success){
        require(safeToMarketPlaceTransfer(msg.sender,this,mProviders[_dataSourceName].price)); // revet state if failed
        // update order
        mOrders[_dataSourceName].push(Order({
            dataSourceName : _dataSourceName,
            subscriber : msg.sender,
            provider : mProviders[_dataSourceName].owner,
            price : mProviders[_dataSourceName].price,
            startTime : now,
            endTime : now + FIXED_SUBSCRIPTION_PERIOD,
            isPaid : false,
            isOrder : true,
            isRefundPaid : false
            }));
        // update provider data 
        mProviders[_dataSourceName].volume = mProviders[_dataSourceName].volume.add(mProviders[_dataSourceName].price);
        mProviders[_dataSourceName].subscriptionsNum = mProviders[_dataSourceName].subscriptionsNum.add(1);
        Subscribed(msg.sender,
            _dataSourceName,
            mProviders[_dataSourceName].owner,
            mProviders[_dataSourceName].price,
            true);
        success = true;
    }
    function getMarketplaceTotalBalance() public view returns (uint256 totalBalance){
        return mToken.balanceOf(this);
    }
    /*internal */

    function handleOrderWithdrawCalc(Order order) internal view returns(uint256 orderAmount){
        orderAmount = 0;
        if(!order.isPaid){ // if not paid yet 
            if(isOrderExpired(order)){ // expired
                if(mProviders[order.dataSourceName].isPunished){ // if punished
                    if(mProviders[order.dataSourceName].punishTimeStamp >= order.endTime){ // punished after expiration date
                        return order.price;
                    }else{ // punished before expiration date
                        return calcRelativeWithdraw(order); //(punishtime / endtime) * amount
                    }
                }else{ // not punished - return full amount
                    return order.price;
                }
            }else{ // not expired
                return orderAmount;
            }
        }
        return orderAmount;
    }
    function handleOrderRefundCalc(Order order) internal view returns(uint256 refundAmount){
        refundAmount = 0;
        if(!order.isRefundPaid){ //order not paid 
            if(mProviders[order.dataSourceName].isPunished){ // provider is punished
                if(mProviders[order.dataSourceName].punishTimeStamp > order.startTime && mProviders[order.dataSourceName].punishTimeStamp < order.endTime){ // punished before the subscription is expired
                   refundAmount = order.price.sub(calcRelativeWithdraw(order)); // price - withdrawPrice
                }
            }
        }
        return refundAmount;
    }
    function calcRelativeWithdraw(Order order) internal view returns(uint256 relativeAmount){
        require(mProviders[order.dataSourceName].isPunished);
         // (punishTime- startTime) * PRICE / (endTime - startTime);
        uint256 price = order.price;
        uint256 a = (mProviders[order.dataSourceName].punishTimeStamp.sub(order.startTime)).mul(price);
        uint256 b = order.endTime.sub(order.startTime);
        return SafeMath.div(a,b);
    }
    function isOrderExpired(Order order) internal view returns (bool isExpired){
        return order.endTime <= now;
    }
    function safeToMarketPlaceTransfer(address _from, address _to, uint256 _amount) 
    internal
    validPrice(_amount)
    returns (bool){
         require(_from != address(0) && _to == address(this));
         require(mToken.allowance(_from,_to) >= _amount);
         require(mToken.transferFrom(_from,_to,_amount));
         SubscriptionDeposited(_from, _to, _amount);
         return true;
    }
    function safeToProviderTransfer(bytes32 _dataSourceName,uint256 _amount) 
    internal 
    validPrice(_amount)
    onlyDataProvider(_dataSourceName) 
    returns (bool){
         require(_amount > 0);
         require(mProviders[_dataSourceName].owner != address(0));
         require(mToken.transfer(mProviders[_dataSourceName].owner,_amount));
         TransferToProvider(mProviders[_dataSourceName].owner,_dataSourceName,_amount);
         return true;
     }
    function safeToSubscriberTransfer(address _subscriber,uint256 _amount) 
    internal 
    validPrice(_amount)
    returns (bool){
        require(_amount > 0);
        require(_subscriber == msg.sender);
        require(mToken.transfer(msg.sender, _amount));
        return true;
    }

}