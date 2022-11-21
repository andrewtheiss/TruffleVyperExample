var Minter = artifacts.require("Minter");

module.exports = function(deployer) {
  //deployer.deploy(ProxyBeaconUpgradable);
  deployer.deploy(Minter);
};

// Deploy a single contract without constructor arguments
//deployer.deploy(A);

// Deploy a single contract with constructor arguments
//deployer.deploy(A, arg1, arg2, ...);

// Don't deploy this contract if it has already been deployed
//deployer.deploy(A, {overwrite: false});

// Set a maximum amount of gas and `from` address for the deployment
//deployer.deploy(A, {gas: 4612388, from: "0x...."});