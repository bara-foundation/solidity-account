// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Account.sol";
import "./IAccountProvider.sol";

contract AccoutProviderStorage {
    event AccountCreated(uint256 accountId, bytes32 slug, address accountAddress);
    event AccountDeleted(uint256 accountId, bytes32 slug, address accountAddress);
    
    mapping(uint256 => address) _accounts;
    
    mapping(bytes32 => uint256) _accountBySlug;
}

/**
* Account contract is use to manage accounts via children contracts,
* which can create a contract account to handle ERC20/721 token.
*/
abstract contract AccountProvider is IAccountProvider, ERC721URIStorage, AccoutProviderStorage {
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
        (uint256 accountId, ) = _createAccount(slug_);
        _mint(_msgSender(), accountId);
    }

    function deleteAccount(bytes32 slug_) external override virtual {
        uint256 accountId = _deleteAccount(slug_);
        _burn(accountId);
    }

    function setAvatar(uint256 accountId_, string memory tokenURI_) external override virtual {
        _setTokenURI(accountId_, tokenURI_);
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

    function _deleteAccount(bytes32 slug_) internal accountExisted(slug_) returns (uint256) {
        uint256 accountId = _accountBySlug[slug_];
        address accountAddress = _accounts[accountId];

        _beforeDeleteAccount(accountId, slug_);

        delete _accounts[accountId];
        delete _accountBySlug[slug_];

        _afterDeleteAccount(accountId, slug_, accountAddress);

        emit AccountDeleted(accountId, slug_, accountAddress);
        return accountId;
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
    
    function totalAccounts() override public view returns (uint256) {
        return _accountIds.current();
    }
}