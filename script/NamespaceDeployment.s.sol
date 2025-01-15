// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Namespace} from "../src/Namespace.sol";
import {DeploymentScript} from "./DeploymentScript.s.sol";

contract NamespaceDeployment is DeploymentScript {
    Namespace public namespace;

    function _run() internal override {
        namespace = new Namespace(vm.addr(vm.envUint("PRIVATE_KEY")));
        _deployedAddress("Namespace", address(namespace));
    }
}
