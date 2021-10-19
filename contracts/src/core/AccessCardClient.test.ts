import { AccessCardClient } from "./AccessCardClient";
import { ethers } from "ethers";

const rpc = "https://dev-1.kardiachain.io";
const smc = process.env.SMC || "0x2CF9077cce73c3bFEA0C754022F32036643dBe0a";
const invokerPK = process.env.PRIVATE_KEY as string;

const provider = new ethers.providers.JsonRpcProvider(rpc);
const signer = new ethers.Wallet(invokerPK, provider);
const acClient = new AccessCardClient(signer, smc);

async function main() {
  const result = await acClient.createWallet("username123", "secret123");
  console.log(result);
}

main()
  .then(() => {
    console.log("Done");
  })
  .catch((err) => console.error(err));
