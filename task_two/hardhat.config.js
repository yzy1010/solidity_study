require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID", // 需要替换为你的 Infura Project ID
      accounts: ["YOUR_PRIVATE_KEY"] // 需要替换为你的私钥
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    }
  },
  paths: {
    sources: "./",
    tests: "./",
    cache: "cache",
    artifacts: "artifacts"
  }
};

