const FenumVesting = artifacts.require('FenumVesting');



module.exports = async function (deployer, network, accounts) {
  const approvers = [accounts[0]];
  const threshold = approvers.length;
  const vesting = "0x"; // VESTING_ADDRESS
  const args = [approvers, threshold, vesting];
  await deployer.deploy(FenumVesting, ...args);
};
