require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.8",
  // settings: {
  //   optimizer: {
  //     enabled: true,
  //     runs: 1000,
  //   },
  // },
  networks: {
    hardhat: {},
    localhost: {
      url: "HTTP://127.0.0.1:7545",
      chainId: 1337,
      accounts: [
        "0x03e63cfbe537b221ac06325117d71b4473933df253a0d94664b38a3056c2a76e",
      ],
    },
  },
};
