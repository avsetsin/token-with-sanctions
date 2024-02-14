// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Token} from "../src/Token.sol";

contract TokenTransfersTest is Test {
    Token public token;
    address owner = address(1);

    function setUp() public {
        token = new Token(owner, "Test Token", "TKN", 100_000);
    }

    // Regular transfers

    function test_Transfer() public {
        address from = address(2);
        address to = address(3);
        uint256 value = 100;

        topUpAccount(from, value);

        assertEq(token.balanceOf(to), 0);
        vm.prank(from);
        token.transfer(to, value);
        assertEq(token.balanceOf(to), value);
    }

    function test_TransferFrom() public {
        address from = address(2);
        address to = address(3);
        address spender = address(4);
        uint256 value = 100;

        topUpAccount(from, value);
        vm.prank(from);
        token.approve(spender, value);

        assertEq(token.balanceOf(to), 0);
        vm.prank(spender);
        token.transferFrom(from, to, value);
        assertEq(token.balanceOf(to), value);
    }

    // Transfers between sanctions list accounts

    function test_TransferFromSanctionedAccount() public {
        address from = address(2);
        address to = address(3);
        uint256 value = 100;

        topUpAccount(from, value);
        addToSanctionList(from);

        vm.prank(from);
        vm.expectRevert(abi.encodeWithSelector(Token.AccountUnderSanctions.selector, from));
        token.transfer(to, value);
    }

    function test_TransferToSanctionedAccount() public {
        address from = address(2);
        address to = address(3);
        uint256 value = 100;

        topUpAccount(from, value);
        addToSanctionList(to);

        vm.prank(from);
        vm.expectRevert(abi.encodeWithSelector(Token.AccountUnderSanctions.selector, to));
        token.transfer(to, value);
    }

    function test_TransferFromToSanctionedAccount() public {
        address from = address(2);
        address to = address(3);
        address spender = address(4);
        uint256 value = 100;

        topUpAccount(from, value);
        vm.prank(from);
        token.approve(spender, value);

        addToSanctionList(to);

        vm.prank(spender);
        vm.expectRevert(abi.encodeWithSelector(Token.AccountUnderSanctions.selector, to));
        token.transferFrom(from, to, value);
    }

    // Helper functions

    function addToSanctionList(address account) internal {
        vm.prank(owner);
        token.addToSanctionList(account);
        assertTrue(token.isUnderSanctions(account));
    }

    function topUpAccount(address account, uint256 value) internal {
        vm.prank(owner);
        token.transfer(account, value);
        assertGe(token.balanceOf(account), value);
    }
}
