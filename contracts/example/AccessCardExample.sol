// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../misc/AccessCard.sol";

contract AccessCardExample is AccessCard, Ownable {
    constructor() payable {}

    function withdraw(uint256 amount) external {
        Address.sendValue(payable(owner()), amount);
    }

    function createCard(string memory cardIdentity_, address publicKey_, string memory encryptedPrivateKey_) public override onlyOwner {
        super.createCard(cardIdentity_, publicKey_, encryptedPrivateKey_);
    }

    function changeKeyPair(string memory cardIdentity_, address publicKey_, string memory encryptedKey_) public override onlyOwner {
        super.changeKeyPair(cardIdentity_, publicKey_, encryptedKey_);
    }
}
