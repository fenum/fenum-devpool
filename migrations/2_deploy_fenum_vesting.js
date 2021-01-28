const FenumVesting = artifacts.require('FenumVesting');



module.exports = async function (deployer, network, accounts) {
  const approvers = [accounts[0]];
  const threshold = approvers.length;
  const token = "0x"; // TOKEN_ADDRESS
  const args = [approvers, threshold, token];
  await deployer.deploy(FenumVesting, ...args);
};
