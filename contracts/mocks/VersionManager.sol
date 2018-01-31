// pragma solidity ^0.4.18;

// // THE EXAMPLES SOURCE https://ethereum.stackexchange.com/questions/1134/what-design-patterns-are-appropriate-for-data-structure-modification-within-ethe/2568

// /*
// There are two main disadvantages to this approach:

// Users must always look up the current address, and anyone who fails to do so risks using an old version of the contract

// You will need to think carefully about how to deal with the contract data when you replace the contract

// The alternate approach is to have a contract forward calls and data to the latest version of the contract:
// */
// contract VersionManager {
//     address backendContract;
//     address[] previousBackends;
//     address owner;

//     function SomeRegister() {
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner)
//         _;
//     }

//     function changeBackend(address newBackend) public
//     onlyOwner()
//     returns (bool)
//     {
//         if(newBackend != backendContract) {
//             previousBackends.push(backendContract);
//             backendContract = newBackend;
//             return true;
//         }

//         return false;
//     }
// }


// // This approach avoids the previous problems but has problems of its own. You must be extremely careful with how you store data in this contract. If your new contract has a different storage layout than the first, your data may end up corrupted. Additionally, this simple version of the pattern cannot return values from functions, only forward them, which limits its applicability. (More complex implementations attempt to solve this with in-line assembly code and a registry of return sizes.)

// // Regardless of your approach, it is important to have some way to upgrade your contracts, or they will become unusable when the inevitable bugs are discovered in them.


// contract Relay {
//     address public currentVersion;
//     address public owner;

//     modifier onlyOwner() {
//         require(msg.sender == owner);
//         _;
//     }

//     function Relay(address initAddr) {
//         currentVersion = initAddr;
//         owner = msg.sender; // this owner may be another contract with multisig, not a single contract owner
//     }

//     function changeContract(address newVersion) public
//     onlyOwner()
//     {
//         currentVersion = newVersion;
//     }

//     function() {
//         require(currentVersion.delegatecall(msg.data));
//     }
// }