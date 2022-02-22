const BUSDToken = artifacts.require("BUSDToken");
const Bank = artifacts.require("Bank");

module.exports = async function(deployer) {
	//deploy Token
	await deployer.deploy(BUSDToken)
	//assign token into variable to get it's address
	const bUSDToken = await BUSDToken.deployed()
	//pass token address for dBank contract(for future minting)
	await deployer.deploy(Bank, bUSDToken.address)
	//assign dBank contract into variable to get it's address
	await Bank.deployed()
	//change token's owner/minter from deployer to dBank
	// await token.passMinterRole(bank.address)
};