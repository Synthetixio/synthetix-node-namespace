// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Script} from "forge-std/src/Script.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {console} from "forge-std/src/console.sol";
import {stdJson} from "forge-std/src/StdJson.sol";

abstract contract DeploymentScript is Script {
    using stdJson for string;

    function run() external {
        vm.startBroadcast();
        _run();
        vm.stopBroadcast();
    }

    function _run() internal virtual;

    function _deployedAddress(string memory name, address addr) internal {
        _writeDeployedAddress(name, addr);
        console.log("Deployed %s at %s", name, Strings.toHexString(uint160(addr), 20));
    }

    function _deployPath() view internal returns (string memory deployPath) {
        deployPath = string.concat("deployments_", Strings.toString(block.chainid), ".json");
    }

    function _writeDeployedAddress(string memory name, address addr) internal {
        if (vm.isFile(_deployPath())) {
            vm.serializeJson("contracts", vm.readFile(_deployPath()));
        }
        string memory newJson = vm.serializeAddress("contracts", name, addr);
        vm.writeJson(newJson, _deployPath());
    }

    function _getDeployedAddress(string memory name) internal view returns (address) {
        string memory json = vm.readFile(_deployPath());
        string memory key = string.concat(".", name);
        return json.readAddress(key);
    }
}
