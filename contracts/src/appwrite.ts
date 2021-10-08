import * as ethers from "ethers";

import { Client, Users } from "node-appwrite";

import AccountProviderArtifact from "../build/contracts/AccountProvider.json";
import { AccountProvider__factory } from "./typechain";
import KardiaClient from "kardia-js-sdk";

const APPWRITE_ENDPOINT = process.env.APPWRITE_ENDPOINT as string;
const APPWRITE_FUNCTION_PROJECT_ID = process.env
  .APPWRITE_FUNCTION_PROJECT_ID as string;
const APPWRITE_API_KEY = process.env.APPWRITE_API_KEY as string;

export const getKardiaContract = (kardiaClient: KardiaClient) => {
  const contractInstance = kardiaClient.contract;

  contractInstance.updateAbi(AccountProvider__factory.abi);
  contractInstance.updateByteCode(AccountProviderArtifact.bytecode);
  return contractInstance;
};

export const getAppWriteClient = (): Client => {
  const client = new Client();
  client
    .setEndpoint(APPWRITE_ENDPOINT)
    .setProject(APPWRITE_FUNCTION_PROJECT_ID)
    .setKey(APPWRITE_API_KEY);
  return client;
};

const getProvider = () => {
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.RPC_ENDPOINT
  );
  return provider;
};

export const deploy = (): Promise<string> => {
  return Promise.resolve("");
};

export type CreateAccountProps = { email: string };
export async function createAccount(
  contractAddress: string,
  { email }: CreateAccountProps,
  provider?: any
) {
  const selectProvider = provider || getProvider();
  const accountProvider = AccountProvider__factory.connect(
    contractAddress,
    selectProvider
  );
  const slug = ethers.utils.formatBytes32String(email);
  const tx = await accountProvider.createAccount(slug);
  const response = await tx.wait();
  const events = response.events;
  console.log(JSON.stringify(events, null, 2));
  // if (events[1].event.name == "AccountRegistered") {
  //   const { accountId, slug, accountAddress } = events[1].event as any;
  //   console.log({ accountId, slug, accountAddress });

  //   const account = new Users(client).updatePrefs(payload.$id, {
  //     smcAddress: accountAddress,
  //   });
  //   console.log(`Updated prefs: ${JSON.stringify(account)}`);
  // }
}
