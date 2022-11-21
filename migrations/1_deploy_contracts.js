var VyperStorage = artifacts.require("VyperStorage");
//var ProxyBeaconUpgradable = artifacts.require("Proxy");

module.exports = function(deployer) {
  //deployer.deploy(ProxyBeaconUpgradable);
  deployer.deploy(VyperStorage);
};
