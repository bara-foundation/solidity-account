// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "../Account.sol";
import "../AccountProvider.sol";

contract AccountExample is Account {
    uint256 private _id;

    constructor(uint256 id_, bytes32 slug_) Account(slug_) {
        _id = id_;
    }
}

contract AccountProviderExample is AccountProvider {
    function _newAccountContract(uint256 id_, bytes32 slug_) internal override returns (address) {
        return address(new AccountExample(id_, slug_));
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
        result := mload(add(source, 32))
        }
    }

    function createAccount(bytes32 slug_) external {
        _createAccount(slug_);
    }

    function deleteAccount(bytes32 slug_) external {
        _deleteAccount(slug_);
    }
}