require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      },
      viaIR: true,
      // ESSENCIAL PARA O EIP-1153 (tstore/tload)
      evmVersion: "cancun"
    }
  },
  networks: {
    hardhat: {
      hardfork: "cancun"
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    noColors: false,
    outputFile: 'results/gas_report.csv',
    reportFormats: ['csv'],
  }
};
