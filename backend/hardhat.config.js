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
        "0x6efb9cfa62e1016acd0f990f84d637f70d1a70ab97d068deb8e9e107d7dae093",
      ],
    },
  },
};
