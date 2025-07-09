import hre from "hardhat";
const { ethers } = hre;
import * as dotenv from "dotenv";
dotenv.config();

async function main() {
  const l2Provider = new ethers.JsonRpcProvider(process.env.L2_RPC_URL);
  const l2Deployer = new ethers.Wallet(process.env.PRIVATE_KEY_1!, l2Provider);

  console.log("Deploying AIHIToken with deployer:", l2Deployer.address);

  const MyTokenFactory = await ethers.getContractFactory("NonMintableToken", l2Deployer);

  const supply = BigInt("199000000") * BigInt("10") ** BigInt("18");
  const l2Token = await MyTokenFactory.deploy(
    "AIHI",
    "AIHI",
    "0x725615fb55fa22F6Ee512836d6d394765809D940",
    supply
  );

  await l2Token.waitForDeployment();

  console.log("✅ AIHIToken deployed at:", await l2Token.getAddress());
}

main().catch((error) => {
  console.error("Deployment failed:", error);
  process.exit(1);
});
