// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IERC20Account {
    function approveFungibleToken(address token_, address spender_, uint256 amount_) external;
}

interface IERC721Account {
    function approveSpecificNonFungibleToken(address token_, address operator_, uint256 tokenId_) external;

    function approveAllNonFungibleToken(address token_, address operator_, bool approved_) external;
}

/**
* A contract which is able to receive any ERC20/ERC721 token
 */
interface IAccount is IERC20Account, IERC721Account, IERC721Receiver {
}