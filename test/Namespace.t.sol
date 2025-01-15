// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Namespace} from "../src/Namespace.sol";
import {CommonBase} from "forge-std/src/Base.sol";
import {StdAssertions} from "forge-std/src/StdAssertions.sol";
import {StdChains} from "forge-std/src/StdChains.sol";
import {StdCheats, StdCheatsSafe} from "forge-std/src/StdCheats.sol";
import {StdUtils} from "forge-std/src/StdUtils.sol";
import {Test} from "forge-std/src/Test.sol";

contract NamespaceTest is Test {
    Namespace public namespace;
    address public owner;
    address public user;

    function setUp() public {
        owner = vm.addr(1);
        user = vm.addr(2);
        vm.prank(owner);
        namespace = new Namespace(owner);
    }

    function testSafeMint() public {
        vm.prank(owner);
        namespace.safeMint("MyNamespace");

        assertEq(namespace.tokenIdToNamespace(1), "MyNamespace");
        assertEq(namespace.namespaceToTokenId("MyNamespace"), 1);

        assertEq(namespace.ownerOf(1), owner);
    }

    function testSafeMintFailsForDuplicateNamespace() public {
        vm.prank(owner);
        namespace.safeMint("UniqueNamespace");

        vm.expectRevert("Namespace is already taken");
        vm.prank(owner);
        namespace.safeMint("UniqueNamespace");
    }
}
