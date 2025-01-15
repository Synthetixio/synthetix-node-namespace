// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script} from "forge-std/src/Script.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {console} from "forge-std/src/console.sol";
import {stdJson} from "forge-std/src/StdJson.sol";

abstract contract DeploymentScript is Script {
    using stdJson for string;

    string public DEPLOYMENTS_PATH = string.concat("deployments_", Strings.toString(vm.envUint("CHAIN_ID")), ".json");

    function run() external {
        uint256 deployerPrivateKey_ = vm.envOr("PRIVATE_KEY", uint256(0));
        if (deployerPrivateKey_ == 0) {
            vm.startBroadcast();
        } else {
            vm.startBroadcast(deployerPrivateKey_);
        }
        _run();

        vm.stopBroadcast();
    }

    function _run() internal virtual;

    function _deployedAddress(string memory name, address addr) internal {
        _writeDeployedAddress(name, addr);
        console.log("Deployed %s at %s", name, Strings.toHexString(uint160(addr), 20));
    }

    function _writeDeployedAddress(string memory name, address addr) internal {
        if (vm.isFile(DEPLOYMENTS_PATH)) {
            vm.serializeJson("contracts", vm.readFile(DEPLOYMENTS_PATH));
        }
        string memory newJson = vm.serializeAddress("contracts", name, addr);
        vm.writeJson(newJson, DEPLOYMENTS_PATH);
    }

    function _getDeployedAddress(string memory name) internal view returns (address) {
        string memory json = vm.readFile(DEPLOYMENTS_PATH);
        string memory key = string.concat(".", name);
        return json.readAddress(key);
    }
}
