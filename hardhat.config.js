/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle");
module.exports = {
  solidity: "0.8.0",
  networks: {
    local: {
      url: 'http://127.0.0.1:7545',
      accounts: [
        '2aba87cdbe6ed1d055f9601f98859b52790b8db5d8658678848cc02541592b50',
        '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d',
        '0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a',
        '0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6',
        '0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a',
      ]
    },
    tkm_test:{
      url: 'https://test1.thinkiumrpc.net',
      accounts: [
        'a39869eba24fab67214bb094a133ca2d4fa685bfd0fcc960c4a76b0c738f8270',

      ]
    },
    bsc_test:{
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      accounts: [
        'a39869eba24fab67214bb094a133ca2d4fa685bfd0fcc960c4a76b0c738f8270',
      ]
    }
  }
};
