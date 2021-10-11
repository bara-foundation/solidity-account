// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "../Account.sol";
import "../extensions/AccountProviderReferrable.sol";

contract AccountExample is Account {
    uint256 private _id;

    constructor(uint256 id_, bytes32 slug_) Account(slug_) {
        _id = id_;
    }
}

contract AccountProviderReferralExample is AccountProviderReferrable {
    constructor() ERC721("Example", "EXP") {
    }

    function _newAccountContract(bytes32 slug_) internal override returns (address) {
        return address(new AccountExample(0, slug_));
    }

    function referById(uint256 referrerId_, uint256 referreeId_) external {
        _refer(referrerId_, referreeId_);
    }
}
