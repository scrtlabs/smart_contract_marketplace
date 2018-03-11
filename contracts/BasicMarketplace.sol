pragma solidity ^0.4.21;
import "./zeppelin-solidity/SafeMath.sol";
import "./zeppelin-solidity/Ownable.sol";
import "./IBasicMarketplace.sol";
contract IERC20 {
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BasicMarketplace is IBasicMarketplace,Ownable{

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
        bool isRefundPaid;
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
    bytes32 public mBegin; 
    bytes32 public mCurrent;
    // number of providers
    uint public mProvidersSize;
	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined (unixTimeStamp)
	uint public constant FIXED_SUBSCRIPTION_PERIOD = 30 days;
    // version number 
    string public constant MARKETPLACE_VERSION = "1";
    // all providers
    mapping(bytes32=>Provider) public mProviders;
    // provider name = > all orders 
    mapping(bytes32=>Order[]) public mOrders;

	function BasicMarketplace(address _tokenAddress) public {
		require(_tokenAddress != address(0));
		mToken = IERC20(_tokenAddress);
        // initiate linked map 
        mProviders[0x0].nextProvider = "";
        mProviders[0x0].name = 0x0;
        mCurrent = mProviders[0x0].name;
        mBegin = mProviders[0x0].name;
        mProvidersSize = 1;
	}

    /*external functioins*/

    function updateDataSourcePrice(bytes32 _dataSourceName, uint256 _newPrice) 
    external 
    onlyDataProvider(_dataSourceName)
    validPrice(_newPrice)
    returns (bool success){
        mProviders[_dataSourceName].price = _newPrice;
        emit PriceUpdate(msg.sender, _dataSourceName,_newPrice);
        success = true;
    }
    function changeDataSourceActivityStatus(bytes32 _dataSourceName,bool _isActive) 
    external 
    onlyDataProvider(_dataSourceName) 
    returns (bool success){
        mProviders[_dataSourceName].isActive = _isActive;
        emit ActivityUpdate(msg.sender, _dataSourceName, _isActive);
        success = true;
    }

    function isActiveDataSource(bytes32 _dataSourceName) external view returns (bool isActive){
        isActive =  mProviders[_dataSourceName].isActive;
    }

    /* public functions */

    function checkAddressSubscription(address _subscriber, bytes32 _dataSourceName) 
    public 
    view 
    returns (address subscriber,
        bytes32 dataSourceName,
        uint price,
        uint startTime,
        uint endTime,
        bool isUnExpired,
        bool isPaid, 
        bool isPunishedProvider,
        bool isOrder){
        uint256 size = mOrders[_dataSourceName].length;
        require(address(0) != _subscriber);
        require(mProviders[_dataSourceName].isProvider);
        if(size > 0){
            for(uint i=size-1;i>=0;i--){
            if(mOrders[_dataSourceName][i].subscriber == _subscriber){
                subscriber = mOrders[_dataSourceName][i].subscriber;
                price = mOrders[_dataSourceName][i].price;
                startTime = mOrders[_dataSourceName][i].startTime;
                endTime = mOrders[_dataSourceName][i].endTime;
                isUnExpired = !isExpiredSubscription(subscriber,_dataSourceName);
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
        }
        return (subscriber,_dataSourceName,price,startTime,endTime,isUnExpired,isPaid,isPunishedProvider,isOrder);
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

    function getOwnerFromName(bytes32 _dataSourceName) public view returns(address owner){
        owner = mProviders[_dataSourceName].owner;
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
    function isExpiredSubscription(address _subscriber, bytes32 _dataSourceName) 
    public
    view 
    returns 
    (bool isExpired){
        uint256 size = mOrders[_dataSourceName].length;
        require(mProviders[_dataSourceName].isProvider);
        require(address(0) != _subscriber);
        if(size>0){
            for(uint i=size-1;i>=0;i--){
                if(mOrders[_dataSourceName][i].subscriber == _subscriber){
                    return now >= mOrders[_dataSourceName][i].endTime;
                }
                if( i==0 ){
                    break;
                }
            }
        }
        isExpired = true;
    }

    /* modifiers */
    modifier validDataProvider(bytes32 _dataSourceName){
        require(mProviders[_dataSourceName].isProvider);
        require(mProviders[_dataSourceName].isActive);
        require(!mProviders[_dataSourceName].isPunished);  
        _;      
    }
    modifier uniqueDataName(bytes32 _dataSourceName) {
        require(_dataSourceName.length > 0);
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