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
        bytes32 providerName;
        address subscriber;
        address provider;
        uint price;
        uint startTime;
        uint endTime;
        bool isPunished;
        bool isPaid;
    }
    struct Provider{
        address owner;
        uint volume;
        uint subscriptionsNum;
        bytes32 name;
        uint price;
        bool isPunished;
        uint punishTime;
        bool isProvider;
    }

	// Enigma Token
	IERC20 public mToken;
	// Fixed time defined (unixTimeStamp)
	uint public constant FIXED_SUBSCRIPTION_PERIOD = 30 days;
	// the Contract deployer
	address mMarketPlaceOwner;
    // contracts total balance
    uint256 public mTotalBalance;
    // all open/closed orders
    Order [] mOrders;
    // all providers
    mapping(bytes32 => Provider) mProviders;

	function Marketplace(address _tokenAddress) public {
		require(_tokenAddress != address(0));
		mToken = IERC20(_tokenAddress);
		mMarketPlaceOwner = msg.sender;
	}
    /* penallty,punishment logic */
    function setPenalty(bytes32 _dataProviderName, bool _isPunished) external ownerOnly providerExist(_dataProviderName) returns(bool){
        mProviders[_dataProviderName].isPunished = _isPunished;
        mProviders[_dataProviderName].punishTime = now;
        return true;
    }
    /* subscriber refund logic */
    
    function getRefundAmount(address _subscriber) external view returns (uint256 available){
        uint accumulated;
        for(uint i=0; i<mOrders.length;i++){
            Order storage order = mOrders[i];
            Provider storage provider = mProviders[order.providerName];
            if(order.subscriber == _subscriber && !order.isPaid){ // not paid yet
                if(isPunished(provider.name)){ // provider punished
                    if(provider.punishTime < order.endTime){ //provider punished before subscription expired 
                        accumulated += calcRelativeRefund(order,provider);
                    }
                }
            }
        }
        return accumulated;
    }
    function calcRelativeRefund(Order _order, Provider _provider) internal view returns(uint256 amount){
        return (1 - _provider.punishTime/ _order.endTime)  * _provider.price;
    }
    /* provider withdraw logic */
    function getWithdrawAmount(bytes32 dataName) external view returns (uint256 available){
        uint256  accumulated;
        for(uint i=0; i<mOrders.length; i++){
            Order storage order = mOrders[i];
            Provider storage provider = mProviders[order.providerName];
            if(order.providerName == dataName && order.providerName == provider.name){
                accumulated += handleGetWithdraw(order,provider);   
            }
        }
        return accumulated;
    }
    function handleGetWithdraw(Order _order, Provider _provider) private view returns(uint256 amount){
        if(_order.providerName == _provider.name && !_order.isPaid){
                if(isExpired(_order)){
                    if(isPunished(_provider.name)){
                        return calcRelativeWithdraw(_order,_provider);
                    }else{
                        return _order.price;
                    }
                }
            }
            return 0;
    }
    function isExpired(Order _order) internal view returns (bool){
        return now > _order.startTime + FIXED_SUBSCRIPTION_PERIOD; 
    }
    function isPunished(bytes32 _dataProviderName) public view returns(bool){
        return mProviders[_dataProviderName].isPunished;
    }
    function calcRelativeWithdraw(Order _order,Provider _provider) internal view returns (uint256 amount){
        if(_provider.punishTime > _order.endTime){
            return _order.price;   
        }
        return (_provider.punishTime / _order.endTime) * _order.price;
    }
    /* modifiers*/
    modifier ownerOnly(){
        require(msg.sender == mMarketPlaceOwner);
        _;
    }
    modifier providerExist(bytes32 _dataProviderName){
        require(mProviders[_dataProviderName].isProvider);
        _;
    }
}