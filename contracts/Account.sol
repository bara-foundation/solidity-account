// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAccount.sol";

contract Account is IAccount, ERC721Holder {
    bytes32 private _slug;
    constructor(bytes32 slug_) {
        _setSlug(slug_);
    }

    function approveFungibleToken(address token_, address spender_, uint256 amount_) public override {
        IERC20(token_).approve(spender_, amount_);
    }

    function approveSpecificNonFungibleToken(address token_, address operator_, uint256 tokenId_) public override {
        IERC721(token_).approve(operator_, tokenId_);
    }

    function approveAllNonFungibleToken(address token_, address operator_, bool approved_) public override {
        IERC721(token_).setApprovalForAll(operator_, approved_);
    }

    function _setSlug(bytes32 slug_) internal {
        require(_slug == 0, "slug already set");
        _slug = slug_;
    }

    function slug() external view override returns (bytes32) {
        return _slug;
    }
}
