const hre = require("hardhat");

async function main() {
  const LandForm = await hre.ethers.getContractFactory("LandForm");
  const contract = await LandForm.deploy({
    gasPrice: hre.ethers.parseUnits("1", "gwei"),
    gasLimit: 3000000
  });

  await contract.waitForDeployment();
  console.log("✅ LandForm deployed to:", contract.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});