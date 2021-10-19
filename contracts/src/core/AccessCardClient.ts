import { AccessCard, AccessCard__factory } from "../typechain";

import CryptoJS from "crypto-js";
import EtherWallet from "ethereumjs-wallet";

export class AccessCardClient {
  private _smc: AccessCard;

  constructor(private _web3Provider: any, private _accessCardAddress: string) {
    this._smc = AccessCard__factory.connect(
      this._accessCardAddress,
      this._web3Provider
    );
  }

  async createWallet(cardIdentity: string, password: string): Promise<any> {
    const newWallet = this._generateKeyPair();
    const encryptedPrivateKey = this._encryptPrivateKey(
      newWallet.privateKey,
      password
    );
    const tx = await this._smc.createCard(
      cardIdentity,
      newWallet.publicKey,
      encryptedPrivateKey,
      { gasLimit: 3000000 }
    );
    const result = await tx.wait();
    if (result.events?.length === 0) {
      throw new Error(`Could not create wallet card`);
    }
    console.log(JSON.stringify({ tx, result }, null, 2));
    return result;
  }

  /**
   * Restore encrypted wallet account retrieve from card with password
   * @param cardIdentity QR code content printed on card
   * @returns Clear private key as string
   */
  async restoreWallet(cardIdentity: string, password: string): Promise<string> {
    const pk = await this._smc.privateKeyOf(cardIdentity);
    return this._decryptPrivateKey(pk, password);
  }

  private _generateKeyPair() {
    const wallet = EtherWallet.generate();
    return {
      publicKey: wallet.getChecksumAddressString(),
      privateKey: wallet.getPrivateKeyString(),
    };
  }

  private _decryptPrivateKey(
    encryptedPrivateKey: string,
    password: string
  ): string {
    return CryptoJS.AES.decrypt(encryptedPrivateKey, password).toString();
  }

  private _encryptPrivateKey(privateKey: string, password: string): string {
    return CryptoJS.AES.encrypt(privateKey, password).toString();
  }
}
