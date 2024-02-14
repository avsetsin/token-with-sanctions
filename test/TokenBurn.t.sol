// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Token} from "../src/Token.sol";

contract TokenBurnTest is Test {
    Token public token;
    address owner = address(1);

    event BurnedSanctionedFunds(address account, uint256 balance);

    function setUp() public {
        token = new Token(owner, "Test Token", "TKN", 100_000);
    }

    // Burn sanctioned funds

    function test_BurnSanctionedFunds() public {
        address account = address(2);
        uint256 value = 100;
        uint256 initialTotalSupply = token.totalSupply();

        topUpAccount(account, value);
        addToSanctionList(account);

        vm.prank(owner);
        token.burnSanctionedFunds(account);
        assertEq(token.balanceOf(account), 0);
        assertEq(token.totalSupply(), initialTotalSupply - value);
    }

    function test_BurnNonSanctionedFunds() public {
        address account = address(2);
        uint256 value = 100;

        topUpAccount(account, value);
        assertFalse(token.isUnderSanctions(account));

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(Token.AccountNotUnderSanctions.selector, account));
        token.burnSanctionedFunds(account);
    }

    // Unauthorized accounts

    function test_BurnSanctionedFundsByStranger() public {
        address account = address(2);
        uint256 value = 100;
        address stranger = address(3);

        topUpAccount(account, value);
        addToSanctionList(account);

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, stranger));
        token.burnSanctionedFunds(account);
    }

    // Events

    function test_BurnSanctionedFundsEmitEvent() public {
        address account = address(2);
        uint256 value = 100;

        topUpAccount(account, value);
        addToSanctionList(account);

        vm.expectEmit(true, true, true, true, address(token));
        emit BurnedSanctionedFunds(account, value);

        vm.prank(owner);
        token.burnSanctionedFunds(account);
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
