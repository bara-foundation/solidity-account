// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/utils/Address.sol";

pragma solidity >=0.7.0 <0.9.0;

interface IAccessCard {
    /**
    * Create and store sensitive data of wallet on chain
    */
    function createCard(string memory cardIdentity_, address publicKey_, string memory encryptedPrivateKey_) external;

    /**
    * Airdrop initial amount of native asset on production blockchain for gas usage
    */
    function setNativeAirdopAmount(uint256 amount_) external;

    /**
    * Change an account behind a card without re-printing the card
    */
    function changeKeyPair(string memory cardIdentity_, address publicKey_, string memory encryptedKey_) external;

    /**
    * For third-party checking if an account behind the card is stil accessible
    */
    function setLockStatus(string memory cardIdentity_, bool flag_) external;
    function isCardLocked(string memory cardIdentity_) external view returns (bool);

    function cardByAddress(address addr_) external view returns (string memory);

    /**
    * Retrieve encrypted in AES-256 private key stored in ledger.
    * @return string cardIdentity_
    * @return string publicKey_
    */
    function cardAt(uint256 cardNo_) external view returns (string memory, address, bool);

    function cardInfo(string memory cardIdentity_) external view returns (address, bool);

    /**
    * Retrieve private key of wallet behind card
    */
    function privateKeyOf(string memory cardIdentity_) external view returns (string memory);

    function totalCards() external view returns (uint256);

    event Deposited(uint256 value);
    event CardCreated(uint256 cardNo_, string cardIdentity_, address publicKey_);
    event CardLocked(string cardIdentity_);
    event CardUnlocked(string cardIdentity_);
    event KeyPairChanged(string cardIdentity_, address oldPublicKey_, address newPublicKey_);
}

/**
* Store small-wallet encrypted account for decentralize application to help spend gas
*/
contract AccessCard is IAccessCard {
    uint256 private _nativeAirdropAmount = 0.1 ether;

    struct Card {
        address publicKey;
        string privateKey;
        bool locked;
    }

    mapping(string => Card) private _cards;
    mapping(address => string) private _cardsByAddress;
    string[] public cardsList;

    function deposit() external payable {
        emit Deposited(msg.value);
    }

    function setNativeAirdopAmount(uint256 amount_) external override virtual {
        _nativeAirdropAmount = amount_;
    }

    function onCardCreated(Card memory card) internal virtual {
        Address.sendValue(payable(card.publicKey), _nativeAirdropAmount);
    }

    function createCard
            (
                string memory cardIdentity_,
                address publicKey_,
                string memory encryptedPrivateKey_
            ) public override virtual {
        Card memory card = Card({
            publicKey: publicKey_,
            privateKey: encryptedPrivateKey_,
            locked: false
        });
        _cards[cardIdentity_] = card;
        _cardsByAddress[publicKey_] = cardIdentity_;
        cardsList.push(cardIdentity_);
        onCardCreated(card);
        emit CardCreated(cardsList.length, cardIdentity_, publicKey_);
    }

    function onKeyPairChanged(string memory cardIdentity_, address oldPublicKey_, address newPublicKey_, string memory oldEncryptedKey_, string memory newEncryptedKey_) internal virtual {}

    function changeKeyPair(string memory cardIdentity_, address publicKey_, string memory encryptedKey_) public override virtual {
        // Reset
        address oldPublicKey = _cards[cardIdentity_].publicKey;
        string memory oldPrivateKey = _cards[cardIdentity_].privateKey;
        _cardsByAddress[oldPublicKey] = "";

        // Assoc
        _cards[cardIdentity_].publicKey = publicKey_;
        _cards[cardIdentity_].privateKey = encryptedKey_;
        _cardsByAddress[publicKey_] = cardIdentity_;
        onKeyPairChanged(cardIdentity_, oldPublicKey, publicKey_, oldPrivateKey, encryptedKey_);
        emit KeyPairChanged(cardIdentity_, oldPublicKey, publicKey_);
    }

    function setLockStatus(string memory cardIdentity_, bool flag_) external override virtual {
       _cards[cardIdentity_].locked = flag_;
    }

    function isCardLocked(string memory cardIdentity_) external view override returns (bool) {
        return _cards[cardIdentity_].locked;
    }

    function cardByAddress(address addr_) external view override returns (string memory) {
        return _cardsByAddress[addr_];
    }

    function privateKeyOf(string memory cardIdentity_) external view override returns (string memory) {
        return _cards[cardIdentity_].privateKey;
    }

    function cardAt(uint256 cardNo_) external view override returns (string memory, address, bool) {
        string memory identity = cardsList[cardNo_];
        Card memory card = _cards[identity];
        return (identity, card.publicKey, card.locked);
    }

    function cardInfo(string memory cardIdentity_) external view override returns (address, bool) {
        Card memory card = _cards[cardIdentity_];
        return (card.publicKey, card.locked);
    }

    function totalCards() external view override returns (uint256) {
        return cardsList.length;
    }

    /**
    * @notice Receive KAI accidentally from someone transfer to this contract
    */
    receive() external payable {
        this.deposit();
    }
}