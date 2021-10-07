// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./Account.sol";
import "./IAccountProvider.sol";

contract AccoutProviderStorage {
    event AccountCreated(uint256 accountId, bytes32 slug, address accountAddress);
    event AccountDeleted(uint256 accountId, bytes32 slug, address accountAddress);
    
    mapping(uint256 => address) _accounts;
    
    mapping(bytes32 => uint256) _accountBySlug;
}

abstract contract AccountProvider is IAccountProvider, AccoutProviderStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _accountIds;
    
    modifier accountNotExisted(bytes32 slug) {
        require(_accountBySlug[slug] == 0, "account existed");
        _;
    }

    modifier accountExisted(bytes32 slug) {
        require(_accountBySlug[slug] > 0, "account not existed");
        _;
    }

    function createAccount(bytes32 slug_) external override virtual {
        _createAccount(slug_);
    }

    function deleteAccount(bytes32 slug_) external override virtual {
        _deleteAccount(slug_);
    }

    function _newAccountContract(bytes32 slug_) internal virtual returns (address) {
        return address(new Account(slug_));
    }

    function _beforeCreateAccount(uint256 id_, bytes32 slug_) internal virtual {}

    function _afterCreateAccount(uint256 id_, bytes32 slug_, address accountAddress_) internal virtual {}

    function _beforeDeleteAccount(uint256 id_, bytes32 slug_) internal virtual {}

    function _afterDeleteAccount(uint256 id_, bytes32 slug_, address accountAddress_) internal virtual {}
    
    function _createAccount(bytes32 slug_) internal accountNotExisted(slug_) returns (uint256, address) {
        _accountIds.increment();
        uint256 accountId = _accountIds.current();

        _beforeCreateAccount(accountId, slug_);

        _accounts[accountId] = _newAccountContract(slug_);
        _accountBySlug[slug_] = accountId;

        _afterCreateAccount(accountId, slug_, _accounts[accountId]);

        emit AccountCreated(accountId, slug_, _accounts[accountId]);
        return (accountId, _accounts[accountId]);
    }

    function _deleteAccount(bytes32 slug_) internal accountExisted(slug_) {
        uint256 accountId = _accountBySlug[slug_];
        address accountAddress = _accounts[accountId];

        _beforeDeleteAccount(accountId, slug_);

        delete _accounts[accountId];
        delete _accountBySlug[slug_];

        _afterDeleteAccount(accountId, slug_, accountAddress);

        emit AccountDeleted(accountId, slug_, accountAddress);
    }

    function isAccount(address accountContract_) override public view returns (bool) {
        bytes32 slug = IAccount(accountContract_).slug();
        uint256 accountId = _accountBySlug[slug];
        return _accounts[accountId] == accountContract_;
    }
    
    function accountById(uint256 accountId_) override public view returns (address) {
        require(accountId_ <= _accountIds.current(), "account not exist");
        return _accounts[accountId_];
    }
    
    function accountBySlug(bytes32 slug_) override public view accountExisted(slug_) returns (address) {
        return _accounts[_accountBySlug[slug_]];
    }
    
    function totalUsers() override public view returns (uint256) {
        return _accountIds.current();
    }
}