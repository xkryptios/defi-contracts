const hre = require("hardhat");

async function main() {
  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const unlockTime = currentTimestampInSeconds + 5;

  const initialValue = hre.ethers.parseEther("50");

  const c1 = await hre.ethers.deployContract("EthInsurance1000", {
    value: initialValue,
  });
  // const c2 = await hre.ethers.deployContract("EthInsurance1000", {
  //   value: initialValue,
  // });
  // const c3 = await hre.ethers.deployContract("EthInsurance1000", {
  //   value: initialValue,
  // });

  await c1.waitForDeployment();
  // await c2.waitForDeployment();
  // await c3.waitForDeployment();

  console.log(
    `contract deployed to ${c1.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
