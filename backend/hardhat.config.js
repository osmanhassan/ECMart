require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.8",
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000,
    },
  },
  networks: {
    localhost: {
      url: "HTTP://127.0.0.1:7545",
      chainId: 1337,
      accounts: [
        "0x7e546bf957dfd14f594b1890a995bfd8d46fa36089cc45cb316d6c9499f43746",
      ],
    },
  },
};
