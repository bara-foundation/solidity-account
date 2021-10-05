// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IAccount.sol";

contract Account is IAccount, ERC721Holder {
    function approveFungibleToken(address token_, address spender_, uint256 amount_) public override {
        IERC20(token_).approve(spender_, amount_);
    }

    function approveSpecificNonFungibleToken(address token_, address operator_, uint256 tokenId_) public override {
        IERC721(token_).approve(operator_, tokenId_);
    }

    function approveAllNonFungibleToken(address token_, address operator_, bool approved_) public override {
        IERC721(token_).setApprovalForAll(operator_, approved_);
    }
}
