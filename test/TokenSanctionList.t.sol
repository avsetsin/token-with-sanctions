// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Token} from "../src/Token.sol";

contract TokenSanctionListTest is Test {
    Token public token;
    address owner = address(1);

    event AddedToSanctionList(address account);
    event RemovedFromSanctionList(address account);

    function setUp() public {
        token = new Token(owner, "Test Token", "TKN", 100_000);
    }

    function test_SanctionListAddingByOwner() public {
        address account = address(2);

        assertFalse(token.isUnderSanctions(account));
        vm.prank(owner);
        token.addToSanctionList(account);
        assertTrue(token.isUnderSanctions(account));
    }

    function test_SanctionListRemovingByOwner() public {
        address account = address(2);

        addToSanctionList(account);
        vm.prank(owner);
        token.removeFromSanctionList(account);
        assertFalse(token.isUnderSanctions(account));
    }

    // Unauthorized accounts

    function test_SanctionListAddingByStranger() public {
        address account = address(2);
        address stranger = address(3);

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger));
        token.addToSanctionList(account);
    }

    function test_SanctionListRemovingByStranger() public {
        address account = address(2);
        address stranger = address(3);

        addToSanctionList(account);
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger));
        token.removeFromSanctionList(account);
    }

    // Events

    function test_SanctionListAddingEmitEvent() public {
        address account = address(2);

        vm.expectEmit(true, true, true, true, address(token));
        emit AddedToSanctionList(account);

        vm.prank(owner);
        token.addToSanctionList(account);
    }

    function test_SanctionListRemovingEmitEvent() public {
        address account = address(2);

        addToSanctionList(account);

        vm.expectEmit(true, true, true, true, address(token));
        emit RemovedFromSanctionList(account);

        vm.prank(owner);
        token.removeFromSanctionList(account);
    }

    // Helper functions

    function addToSanctionList(address account) internal {
        vm.prank(owner);
        token.addToSanctionList(account);
        assertTrue(token.isUnderSanctions(account));
    }
}
