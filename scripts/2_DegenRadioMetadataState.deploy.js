// npx hardhat run scripts/2_DegenRadioMetadataState.deploy.js --network degen

const contractName = "DegenRadioMetadataState";
const pauseLength = 4000; // in milliseconds

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // deploy contract
  const contract = await ethers.getContractFactory(contractName);
  const instance = await contract.deploy();
  await instance.deployed();
  
  console.log(contractName + " contract address:", instance.address);

  try {
    console.log("Wait a bit before starting the verification process...");
    sleep(pauseLength);
    await hre.run("verify:verify", {
      address: instance.address,
      //constructorArguments: [],
    });
  } catch (error) {
    console.error(error);
  } finally {
    console.log("If automated verification did not succeed, try to verify the smart contract manually by running this command:");
    // TODO:
    console.log("npx hardhat verify --network " + network.name + " " + instance.address);
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });