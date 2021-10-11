// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Arrays.sol";

import "../AccountProvider.sol";

interface IAccountProviderReferrable {
    function isReferrerOf(uint256 referrerId_, uint256 refereeId_) external view returns (bool);

    function referrerOf(uint256 accountId_) external view returns (uint256);

    function referrees(uint256 accountId_) external view returns (uint256[] memory);

    function referLevelBetween(uint256 targetReferrerId_, uint256 refereeId_) external view returns (uint256);
}

abstract contract AccountProviderReferrable is IAccountProviderReferrable, AccountProvider {
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
        require(referrerId_ > 0 && referreeId_ > 0, "AccountProviderReferrable: id > 0");
        require(referrerId_ < totalAccounts() && referreeId_ < totalAccounts(), "AccountProviderReferrable: id < totalAccounts");
        require(_referrers[referreeId_] == 0, "AccountProviderReferrable: link existed");
        _referrers[referreeId_] = referrerId_;
        _referrees[referrerId_].push(referreeId_);
    }

    function referrerOf(uint256 accountId_) override public virtual view returns (uint256) {
        return _referrers[accountId_];
    }

    function referrees(uint256 accountId_) override public virtual view returns (uint256[] memory) {
        return _referrees[accountId_];
    }

    function referLevelBetween(uint256 targetReferrerId_, uint256 refereeId_) override public virtual view returns (uint256) {
        return _referLevelBetween(targetReferrerId_, refereeId_);
    }

    function isReferrerOf(uint256 referrerId_, uint256 refereeId_) override public virtual view returns (bool) {
        return _isReferrerOf(referrerId_, refereeId_);
    }

    function _referLevelBetween(uint256 targetReferrerId_, uint256 refereeId_) internal view returns (uint256) {
        uint256 level = 0;
        uint256 nextReferree = refereeId_;
        uint256 nextReferrer = referrerOf(refereeId_);
        while (_isReferrerOf(nextReferrer, nextReferree)) {
            level += 1;
            if (nextReferrer == targetReferrerId_) { // Terminate loop when reach the target account
                break;
            }
            nextReferree = nextReferrer;
            nextReferrer = referrerOf(nextReferrer);
        }
        if (nextReferrer != targetReferrerId_) { // If reach the final but not connect to the root account, we terminate the referals chain
            level = 0;
        }
        return level;
    }

    function _isReferrerOf(uint256 referrerId_, uint256 refereeId_) internal view returns (bool) {
        uint256 upstairId = referrerOf(refereeId_);
        return upstairId == referrerId_;
    }
}