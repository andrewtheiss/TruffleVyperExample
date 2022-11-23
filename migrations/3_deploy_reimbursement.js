var Reimbursement = artifacts.require("Reimbursement");


module.exports = function(deployer, network, accounts) {
  //deployer.deploy(ProxyBeaconUpgradable);
  const accountOne = accounts[0];
  deployer.deploy(Reimbursement, accounts[0], {from: accountOne});
};


// Deploy A, then deploy B, passing in A's newly deployed address
/*deployer.deploy(A).then(function() {
    return deployer.deploy(B, A.address);
  });
  */
// Deploy a single contract without constructor arguments
//deployer.deploy(A);

// Deploy a single contract with constructor arguments
//deployer.deploy(A, arg1, arg2, ...);

// Don't deploy this contract if it has already been deployed
//deployer.deploy(A, {overwrite: false});

// Set a maximum amount of gas and `from` address for the deployment
//deployer.deploy(A, {gas: 4612388, from: "0x...."});