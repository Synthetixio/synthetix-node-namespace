// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Namespace} from "../src/Namespace.sol";
import {DeploymentScript} from "./DeploymentScript.s.sol";
import {CommonBase} from "forge-std/src/Base.sol";
import {StdChains} from "forge-std/src/StdChains.sol";
import {StdCheatsSafe} from "forge-std/src/StdCheats.sol";
import {StdUtils} from "forge-std/src/StdUtils.sol";

contract NamespaceDeployment is DeploymentScript {
    Namespace public namespace;

    function _run() internal override {
        namespace = new Namespace(vm.addr(vm.envUint("PRIVATE_KEY")), vm.addr(vm.envUint("WHITELIST_ADDRESS")));
        _deployedAddress("Namespace", address(namespace));
    }
}
