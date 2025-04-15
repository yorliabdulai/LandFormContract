require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

const PRIVATE_KEY = process.env.VITE_APECHAIN_PRIVATE_KEY;
const APECHAIN_RPC_URL = process.env.VITE_APECHAIN_RPC_URL;

module.exports = {
  solidity: "0.8.28",
  networks: {
    apechain: {
      url: APECHAIN_RPC_URL,
      accounts: [PRIVATE_KEY]
    },
    curtis: {
      url: APECHAIN_RPC_URL,
      accounts: [
        PRIVATE_KEY
      ],
    }
  },
  };
