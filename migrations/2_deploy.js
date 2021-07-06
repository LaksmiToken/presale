// SPDX-License-Identifier: MIT
const LaksmiToken = artifacts.require('LaksmiToken')
const LaksmiCrowdsale = artifacts.require('LaksmiCrowdsale')

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(
    LaksmiToken,
    'Laksmi Pre Sale Token', // Name of token
    'LKPS',
    '15000000000000000000000000', // Max supply * 10^18
  )
  const token = await LaksmiToken.deployed()

  await deployer.deploy(
    LaksmiCrowdsale,
    33, // Number of token that can be purchased in $1
    "0x2a27fC3bFdA054393ea13c6ff198119358dB191E", // Spender Address
    token.address,
    Math.floor(new Date('2021-07-07').getTime() / 1000), // Start time
    Math.floor(new Date('2021-07-08').getTime() / 1000), //End time
    '66000000000000000000000', // Minimum token that can be purchased
    "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526" // Chainlink BNB/USD price contract, this is a testnet address
  )
  const crowdsale = await LaksmiCrowdsale.deployed()

  token.transfer(crowdsale.address, await token.totalSupply())
}
