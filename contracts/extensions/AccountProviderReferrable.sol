// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Arrays.sol";

import "../AccountProvider.sol";

abstract contract AccountProviderReferrable is AccountProvider {
    using Arrays for uint256[];

    /**
    * Store list of referrees by an account.
    */
    mapping (uint256 => uint256[]) private _referrees;

    /**
    * Store which account is the one who refer an account.
    */
    mapping (uint256 => uint256) private _referrers;

    /**
    * Store referal connection.
    * @param referrerId_ A person who refers another person.
    * @param referreeId_ A person who was referred by another person.
    */
    function _refer(uint256 referrerId_, uint256 referreeId_) internal virtual {
        require(referrerId_ > 0 && referreeId_ > 0, "id must greater than 0");
        require(_referrers[referreeId_] == 0, "referree already referred");
        _referrers[referreeId_] = referrerId_;
        _referrees[referrerId_].push(referreeId_);
    }

    function referrerOf(uint256 accountId_) public virtual view returns (uint256) {
        return _referrers[accountId_];
    }

    function referrees(uint256 accountId_) public virtual view returns (uint256[] memory) {
        return _referrees[accountId_];
    }

    function _referLevelBetween(uint256 targetReferrerId_, uint256 refereeId_) internal view returns (uint256) {
        uint256 level = 0;
        uint256 nextReferree = refereeId_;
        uint256 nextReferrer = referrerOf(refereeId_);
        while (_isReferrerOf(nextReferrer, nextReferree)) {
            level += 1;
            nextReferree = nextReferrer;
            nextReferrer = referrerOf(nextReferrer);
            if (nextReferrer != targetReferrerId_) {
                break;
            }
        }
        return level;
    }

    function _isReferrerOf(uint256 referrerId_, uint256 refereeId_) internal view returns (bool) {
        uint256 upstairId = referrerOf(refereeId_);
        return upstairId == referrerId_;
    }
}