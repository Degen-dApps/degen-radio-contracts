// npx hardhat run scripts/4_DegenRadioFactory.deploy.js --network sepolia

const contractName = "DegenRadioFactory";
const pauseLength = 4000; // in milliseconds

// TODO:
const constructorArgs = [
  "0xbb6fca36B0d0107773a410103e9f1f459C3eb95e" // Playlist NFT contract address
];

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // deploy contract
  const contract = await ethers.getContractFactory(contractName);
  const instance = await contract.deploy(
    // TODO:
    constructorArgs[0]
  );
  await instance.deployed();
  
  console.log(contractName + " contract address:", instance.address);

  // create playlist nft contract
  const playlistNftContract = await ethers.getContractFactory("DegenRadioPlaylistNft");
  const playlistNftInstance = await playlistNftContract.attach(constructorArgs[0]);

  console.log("Playlist NFT contract created.");

  // set factory contract to playlist nft contract as writer
  await playlistNftInstance.addWriter(instance.address);

  console.log("Factory address added as writer in Playlist NFT contract.");

  try {
    console.log("Wait a bit before starting the verification process...");
    sleep(pauseLength);
    await hre.run("verify:verify", {
      address: instance.address,
      constructorArguments: constructorArgs,
    });
  } catch (error) {
    console.error(error);
  } finally {
    console.log("If automated verification did not succeed, try to verify the smart contract manually by running this command:");
    // TODO:
    console.log("npx hardhat verify --network " + network.name + " " + instance.address + ' ' + constructorArgs[0]);
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