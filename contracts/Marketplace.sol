pragma solidity ^0.4.18;


//import "./IMarketplace.sol";
import "./zeppelin-solidity/SafeMath.sol";

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


contract Marketplace{ //is IMarketplace{

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

    // pointer to linked listen 
    bytes32 mBegin; 
    bytes32 mCurrent;
    uint mProvidersSize;
	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined (unixTimeStamp)
	uint public constant FIXED_SUBSCRIPTION_PERIOD = 30 days;
	// the Contract deployer
	address mMarketPlaceOwner;
    // all providers
    mapping(bytes32=>Provider) mProviders;
    mapping(bytes32=>Order[]) mOrders;

	function Marketplace(address _tokenAddress) public {
		require(_tokenAddress != address(0));
		mToken = IERC20(_tokenAddress);
		mMarketPlaceOwner = msg.sender;
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
        mProviders[_dataSourceName].isPunished = _isPunished;
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
    function mockPayableProvider(bytes32 _dataSourceName, uint _price, address _dataOwner)public returns(bool){
        // add mock provider 
        mProviders[_dataSourceName].owner = _dataOwner;
        mProviders[_dataSourceName].volume = 0;
        mProviders[_dataSourceName].subscriptionsNum = 0;
        mProviders[_dataSourceName].name = _dataSourceName;
        mProviders[_dataSourceName].price = _price;
        mProviders[_dataSourceName].isPunished = true;
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
        ActivityUpdate(msg.sender, _dataSourceName, true);
        return true;
    }
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
    function register(bytes32 _dataSourceName, uint _price, address _dataOwner) 
    public
    uniqueDataName(_dataSourceName)
    validPrice(_price)
    returns (bool){
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
        return true;
    }

    function subscribe(bytes32 _dataSourceName) 
    public 
    validDataProvider(_dataSourceName)
    returns (bool){
        bool success = safeToMarketPlaceTransfer(msg.sender,this,mProviders[_dataSourceName].price);
        require(success);
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
        return true;
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
    // when a subscriber registers they move tokens to the contract
    function safeToMarketPlaceTransfer(address _from, address _to, uint256 _amount) internal returns (bool){
         require( _from != address(0) && _to != address(0));
         require(mToken.allowance(_from,address(this)) >= _amount);
         require(mToken.transferFrom(_from,_to,_amount));
         SubscriptionDeposited(_from, _to, _amount);
         return true;
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
        return true;
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
        return (mProviders[_dataSourceName].owner,
            mProviders[_dataSourceName].price,
            mProviders[_dataSourceName].volume,
            mProviders[_dataSourceName].subscriptionsNum,
            mProviders[_dataSourceName].isProvider,
            mProviders[_dataSourceName].isActive,
            mProviders[_dataSourceName].isPunished);
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
    modifier onlyOwner(){
        require(msg.sender == mMarketPlaceOwner);
        _;
    }
    /* events - move to the interface later */
    event Registered(address indexed dataOwner, bytes32 indexed dataSourceName, uint price, bool success);
	event SubscriptionDeposited(address indexed from, address indexed to, uint256 value);
	event Subscribed(address indexed subscriber,bytes32 indexed dataSourceName, address indexed dataOwner, uint price, bool success);
	event PriceUpdate(address indexed editor, bytes32 indexed dataSourceName, uint256 newPrice);
	event ActivityUpdate(address indexed editor, bytes32 indexed dataSourceName, bool newStatus);
	// new events 
	// provifer got paid 
	event TransferToProvider(address indexed dataOwner, bytes32 indexed _dataSourceName, uint256 _amount);
	// provider finished withdraw process
	event ProviderWithdraw(address indexed dataOwner, bytes32 indexed _dataSourceName, uint _amount);
}