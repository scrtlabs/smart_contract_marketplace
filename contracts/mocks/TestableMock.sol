// pragma solidity ^0.4.18;


// import "../IMarketplace.sol";
// import "../zeppelin-solidity/SafeMath.sol";
// import "../zeppelin-solidity/Ownable.sol";

// contract IERC20 {
//   function balanceOf(address who) public constant returns (uint256);
//   function transfer(address to, uint256 value) public returns (bool);
//   function allowance(address owner, address spender) public constant returns (uint256);
//   function transferFrom(address from, address to, uint256 value) public returns (bool);
//   function approve(address spender, uint256 value) public returns (bool);
//   event Transfer(address indexed from, address indexed to, uint256 value);
//   event Approval(address indexed owner, address indexed spender, uint256 value);
// }


// contract TestableMock is Marketplace{
//     function mockPayableProvider(bytes32 _dataSourceName, uint _price, address _dataOwner, bool isPunished)
//     public returns(bool){
//         // add mock provider 
//         mProviders[_dataSourceName].owner = _dataOwner;
//         mProviders[_dataSourceName].volume = 0;
//         mProviders[_dataSourceName].subscriptionsNum = 0;
//         mProviders[_dataSourceName].name = _dataSourceName;
//         mProviders[_dataSourceName].price = _price;
//         mProviders[_dataSourceName].isPunished = isPunished;
//         mProviders[_dataSourceName].punishTimeStamp = now/2 - FIXED_SUBSCRIPTION_PERIOD/2;
//         mProviders[_dataSourceName].isProvider = true;
//         mProviders[_dataSourceName].isActive = true;
//         mProviders[_dataSourceName].nextProvider = "";
//         mProviders[mCurrent].nextProvider = _dataSourceName;
//         mCurrent = mProviders[_dataSourceName].name;
//         mProvidersSize = mProvidersSize.add(1);
//         // add order 
//             mOrders[_dataSourceName].push(Order({
//             dataSourceName : _dataSourceName,
//             subscriber : msg.sender,
//             provider : mProviders[_dataSourceName].owner,
//             price : mProviders[_dataSourceName].price,
//             startTime : now/2 - FIXED_SUBSCRIPTION_PERIOD,
//             endTime : now/2,
//             isPaid : false,
//             isOrder : true,
//             isRefundPaid : false
//             }));
//         // update provider data 
//         mProviders[_dataSourceName].volume = mProviders[_dataSourceName].volume.add(mProviders[_dataSourceName].price);
//         mProviders[_dataSourceName].subscriptionsNum = mProviders[_dataSourceName].subscriptionsNum.add(1);
//         return true;
//     }

// }