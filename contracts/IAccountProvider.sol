// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

interface IAccountProvider {
    function createAccount(bytes32 slug_) external;
    function deleteAccount(bytes32 slug_) external;
    function setAvatar(uint256 accountId_, string memory tokenURI_) external;
    function isAccount(address accountContract_) external view returns (bool);    
    function accountById(uint256 accountId_) external view returns (address);    
    function accountBySlug(bytes32 slug_) external view returns (address);    
    function totalAccounts() external view returns (uint256);
}