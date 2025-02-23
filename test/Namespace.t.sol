// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Namespace} from "../src/Namespace.sol";
import {Whitelist} from "../src/Whitelist.sol";
import {CommonBase} from "forge-std/src/Base.sol";
import {StdAssertions} from "forge-std/src/StdAssertions.sol";
import {StdChains} from "forge-std/src/StdChains.sol";
import {StdCheats, StdCheatsSafe} from "forge-std/src/StdCheats.sol";
import {StdUtils} from "forge-std/src/StdUtils.sol";
import {Test} from "forge-std/src/Test.sol";

contract NamespaceTest is Test {
    Namespace public namespace;
    Whitelist public whitelist;

    address public owner;
    address public user;
    address public admin;

    function setUp() public {
        owner = vm.addr(1);
        user = vm.addr(2);
        admin = vm.addr(3);

        vm.prank(owner);
        whitelist = new Whitelist();

        vm.prank(owner);
        namespace = new Namespace(owner, address(whitelist));
    }

    function testSafeMintWithGrantedRole() public {
        vm.prank(owner);
        whitelist.approveApplication(user);

        vm.prank(user);
        namespace.safeMint("exampleNamespace");

        assertEq(namespace.namespaceToTokenId("exampleNamespace"), 1);
        assertEq(namespace.tokenIdToNamespace(1), "exampleNamespace");
        assertEq(namespace.ownerOf(1), user);
    }

    function testSafeMintWithoutGrantedRole() public {
        vm.expectRevert("Not allowed");
        vm.prank(user);
        namespace.safeMint("exampleNamespace");
    }

    function testOwnerCanSetNewWhitelist() public {
        address newWhitelist = vm.addr(4);

        vm.prank(owner);
        namespace.setWhitelist(newWhitelist);

        assertEq(address(namespace.whitelist()), newWhitelist);
    }

    function testSetWhitelistByNonOwner() public {
        address newWhitelist = vm.addr(4);

        vm.expectRevert();
        vm.prank(user);
        namespace.setWhitelist(newWhitelist);
    }

    function testSetWhitelistToZeroAddress() public {
        vm.expectRevert("New whitelist contract address cannot be the zero address.");
        vm.prank(owner);
        namespace.setWhitelist(address(0));
    }

    function testMintDuplicateNamespace() public {
        vm.prank(owner);
        whitelist.approveApplication(user);

        vm.prank(user);
        namespace.safeMint("duplicateNamespace");

        vm.expectRevert("Namespace is already taken");
        vm.prank(user);
        namespace.safeMint("duplicateNamespace");
    }
}
