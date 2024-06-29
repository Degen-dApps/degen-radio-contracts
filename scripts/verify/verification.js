// Before running this script, make sure to enter data in the arguments.js file.
// npx hardhat run scripts/verify/verification.js --network sepolia 

const contractAddress = "0x0Dd272d469fB118f26Db72563f501Bb522AC2A95"; // enter the address of the contract you want to verify

const constructorArgs = [
  2, // playlistId
  "0xbb6fca36B0d0107773a410103e9f1f459C3eb95e", // playlist NFT address
  "0x333f5CebEB227563DCc37BA15cd47EC827d5386b", // track NFT address
  1, // track NFT token ID
  666666666 // track NFT chain ID
];

async function main() {
  console.log("Verifying contract at address:", contractAddress);
  console.log("");

  try {
    await hre.run("verify:verify", {
      address: contractAddress,
      constructorArguments: constructorArgs,
    });
  } catch (error) {
    console.error(error);
  } finally {
    console.log("If automated verification did not succeed, try to verify the smart contract manually by running this command:");
    // TODO:
    console.log("npx hardhat verify --network " + network.name + " " + contractAddress + ' "' + constructorArgs[0] + '" ' + constructorArgs[1] + ' ' + constructorArgs[2] + ' "' + constructorArgs[3] + '" "' + constructorArgs[4] + '"');
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });