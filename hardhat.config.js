require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: 'hardhat',

  networks: {
    hardhat: {
      gas: "auto", // gas limit
    },
    degen: { // DEGEN L3 Chain mainnet
      url: 'https://rpc.degen.tips',
      chainId: 666666666,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
      gas: "auto", // gas limit
      gasPrice: 100000000000, // 100 gwei
    },
    sepolia: { // Sepolia testnet
      url: 'https://eth-sepolia.public.blastapi.io',
      chainId: 11155111,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
      gas: "auto", // gas limit
      gasPrice: 15000000000, // 15 gwei
    },
  },

  /* Verification on the Degen block explorer */
  etherscan: {
    apiKey: { 
      degen: "somestring", // no API key is needed, but it cannot be an empty string either
      sepolia: process.env.ETHERSCAN_API_KEY,
    },

    customChains: [
      {
        network: "degen",
        chainId: 666666666,
        urls: {
          apiURL: "https://explorer.degen.tips/api",
          browserURL: "https://explorer.degen.tips"
        }
      }
    ]
  },

  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true
  },

  solidity: {
    compilers: [
      {
        version: "0.8.24", // enter the version of solidity your contracts are using
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ],
    
  }
};
