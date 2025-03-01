// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Whitelist} from "../src/Whitelist.sol";
import {Namespace} from "../src/Namespace.sol";
import {DeploymentScript} from "./DeploymentScript.s.sol";
import {CommonBase} from "forge-std/src/Base.sol";
import {StdChains} from "forge-std/src/StdChains.sol";
import {StdCheatsSafe} from "forge-std/src/StdCheats.sol";
import {StdUtils} from "forge-std/src/StdUtils.sol";

contract NamespaceDeployment is DeploymentScript {
    Namespace public namespace;
    Whitelist public whitelist;

    function _run() internal override {
        whitelist = new Whitelist(msg.sender);
        namespace = new Namespace(msg.sender, address(whitelist));
        _deployedAddress("Whitelist", address(whitelist));
        _deployedAddress("Namespace", address(namespace));
    }
}
