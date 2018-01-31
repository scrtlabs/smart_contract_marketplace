pragma solidity ^0.4.18;


import "./IMarketplace.sol";
import "./zeppelin-solidity/SafeMath.sol";
import "./zeppelin-solidity/Ownable.sol";

contract IERC20 {
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Marketplace is Ownable,IMarketplace{

	using SafeMath for uint256;
	using SafeMath for uint;

	/*Data structures */

	struct Order{
        bytes32 dataSourceName;
        address subscriber;
        address provider;
        uint price;
        uint startTime;
        uint endTime;
        bool isPaid;
        bool isOrder;
    }
    struct Provider{
        address owner;
        uint volume;
        uint subscriptionsNum;
        bytes32 name;
        uint price;
        bool isPunished;
        uint punishTimeStamp;
        bool isProvider;
        bool isActive;
        bytes32 nextProvider;
    }
    // pointers to linked list of Providers
    bytes32 mBegin; 
    bytes32 mCurrent;
    // number of providers
    uint mProvidersSize;
	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined (unixTimeStamp)
	uint public constant FIXED_SUBSCRIPTION_PERIOD = 30 days;
    // version number 
    string public constant MARKETPLACE_VERSION = "1";
    // all providers
    mapping(bytes32=>Provider) public mProviders;
    mapping(bytes32=>Order[]) public mOrders;

	function Marketplace(address _tokenAddress) public {
		require(_tokenAddress != address(0));
		mToken = IERC20(_tokenAddress);
        // initiate linked map 
        mProviders[0x0].nextProvider = "";
        mProviders[0x0].name = 0x0;
        mCurrent = mProviders[0x0].name;
        mBegin = mProviders[0x0].name;
        mProvidersSize = 1;
	}
    function setPunishProvider(bytes32 _dataSourceName, bool _isPunished) 
    public 
    onlyOwner 
    returns (bool success){
        require(mProviders[_dataSourceName].isProvider);
        mProviders[_dataSourceName].isPunished = _isPunished;
        ProviderPunishStatus(mProviders[_dataSourceName].owner,_dataSourceName,_isPunished);
        success = true;
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
            isOrder : true
            }));
        // update provider data 
        mProviders[_dataSourceName].volume = mProviders[_dataSourceName].volume.add(mProviders[_dataSourceName].price);
        mProviders[_dataSourceName].subscriptionsNum = mProviders[_dataSourceName].subscriptionsNum.add(1);
        return true;
    }
    function updateDataSourcePrice(bytes32 _dataSourceName, uint256 _newPrice) 
    external 
    onlyDataProvider(_dataSourceName)
    validPrice(_newPrice)
    returns (bool success){
        mProviders[_dataSourceName].price = _newPrice;
        PriceUpdate(msg.sender, _dataSourceName,_newPrice);
        success = true;
    }
    function changeDataSourceActivityStatus(bytes32 _dataSourceName,bool _isActive) 
    external 
    onlyDataProvider(_dataSourceName) 
    returns (bool success){
        mProviders[_dataSourceName].isActive = _isActive;
        ActivityUpdate(msg.sender, _dataSourceName, _isActive);
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
                refundAmount = refundAmount.add(refund);
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
            if(withdraw > 0){ // mark order as paid 
                mOrders[_dataSourceName][i].isPaid = true;
            }
            withdrawAmount = withdrawAmount.add(withdraw); 
            success = true;
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
            isOrder : true
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

    function checkAddressSubscription(address _subscriber, bytes32 _dataSourceName) 
    public 
    view 
    returns (address subscriber,
        bytes32 dataSourceName,
        uint price,
        uint startTime,
        uint endTime,
        bool isExpired,
        bool isPaid, 
        bool isPunishedProvider,
        bool isOrder){
        uint256 size = mOrders[_dataSourceName].length;
        require(size>0);
        require(address(0) != _subscriber);
        require(mProviders[_dataSourceName].isProvider);
        for(uint i=size-1;i>=0;i--){
            if(mOrders[_dataSourceName][i].subscriber == _subscriber){
                subscriber = mOrders[_dataSourceName][i].subscriber;
                price = mOrders[_dataSourceName][i].price;
                startTime = mOrders[_dataSourceName][i].startTime;
                endTime = mOrders[_dataSourceName][i].endTime;
                isExpired = isExpiredSubscription(subscriber,_dataSourceName);
                isPaid = mOrders[_dataSourceName][i].isPaid;
                isPunishedProvider = mProviders[_dataSourceName].isPunished;
                isOrder = mOrders[_dataSourceName][i].isOrder;
                i = 0;
                break;
            }
            if( i==0 ){
                break;
            }
        }
        return (subscriber,_dataSourceName,price,startTime,endTime,isExpired,isPaid,isPunishedProvider,isOrder);
    }

    function getAllProviders() public view returns (bytes32[]){
        bytes32[] memory names = new bytes32[](mProvidersSize);
        bytes32 iterator = mBegin;
        for(uint i=0; i< mProvidersSize; ++i){
            names[i] = mProviders[iterator].name;
            iterator = mProviders[iterator].nextProvider;
        }
        return names;
    }
    function isExpiredSubscription(address _subscriber, bytes32 _dataSourceName) 
    public
    view 
    returns 
    (bool isExpired){
        uint256 size = mOrders[_dataSourceName].length;
        require(size>0);
        require(mProviders[_dataSourceName].isProvider);
        require(address(0) != _subscriber);
        for(uint i=size-1;i>=0;i--){
            if(mOrders[_dataSourceName][i].subscriber == _subscriber){
                return now >= mOrders[_dataSourceName][i].endTime;
            }
            if( i==0 ){
                break;
            }
        }
        isExpired = true;
    }
    function getDataProviderInfo(bytes32 _dataSourceName) 
    public 
    view 
    returns(
        address owner,
        uint256 price,
        uint256 volume,
        uint256 subscriptionsNum,
        bool isProvider,
        bool isActive,
        bool isPunished){
        owner = mProviders[_dataSourceName].owner;
        price = mProviders[_dataSourceName].price;
        volume = mProviders[_dataSourceName].volume;
        subscriptionsNum = mProviders[_dataSourceName].subscriptionsNum;
        isProvider = mProviders[_dataSourceName].isProvider;
        isActive = mProviders[_dataSourceName].isActive;
        isPunished = mProviders[_dataSourceName].isPunished;
    }
    function getMarketplaceTotalBalance() public view returns (uint256 totalBalance){
        return mToken.balanceOf(this);
    }
    function isActiveDataSource(bytes32 _dataSourceName) external view returns (bool isActive){
        isActive =  mProviders[_dataSourceName].isActive;
    }
    function getOwnerFromName(bytes32 _dataSourceName) public view returns(address owner){
        owner = mProviders[_dataSourceName].owner;
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
    function handleOrderRefundCalc(Order order) internal returns(uint256 refundAmount){
        refundAmount = 0;
        if(!order.isPaid){ //order not paid 
            if(mProviders[order.dataSourceName].isPunished){
                if(mProviders[order.dataSourceName].punishTimeStamp > order.startTime && mProviders[order.dataSourceName].punishTimeStamp < order.endTime){ // punished before the subscription is expired
                   refundAmount = order.price.sub(calcRelativeWithdraw(order)); // price - withdrawPrice
                }
            }
        }
        return refundAmount;
    }
    function calcRelativeWithdraw(Order order) internal view returns(uint256 relativeAmount){
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
         require(_from != address(0) && _to != address(0));
         require(mToken.allowance(_from,address(this)) >= _amount);
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
    /* modifiers */
    modifier validDataProvider(bytes32 _dataSourceName){
        require(mProviders[_dataSourceName].isProvider);
        require(mProviders[_dataSourceName].isActive);
        require(!mProviders[_dataSourceName].isPunished);  
        _;      
    }
    modifier uniqueDataName(bytes32 _dataSourceName) {
        require(!mProviders[_dataSourceName].isProvider);
        _;
    }
    modifier validPrice (uint256 _price){
        require(_price.add(1) > _price); //overflow
        _;
    }
    modifier onlyDataProvider(bytes32 _dataSourceName){
        require(mProviders[_dataSourceName].isProvider);
        require(mProviders[_dataSourceName].owner == msg.sender);
        _;
    }
}