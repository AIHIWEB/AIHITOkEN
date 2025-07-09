import * as dotenv from "dotenv";
dotenv.config();

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "@typechain/hardhat";

const config: HardhatUserConfig = {
  solidity: "0.8.20",

  typechain: {
    outDir: "typechain-types",
    target: "ethers-v6",
  },

  networks: {
    customnet: {
      url: process.env.L2_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY_1 ? [process.env.PRIVATE_KEY_1] : [],
    },
  },
};

export default config;
