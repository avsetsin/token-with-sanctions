// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenSetupTest is Test {
    Token public token;
    address owner = address(1);

    function setUp() public {
        token = new Token(owner, "Sanction Token", "TKN", 100_000);
    }

    function test_Owner() public {
        assertEq(token.owner(), owner);
    }

    function test_TokenName() public {
        assertEq(token.name(), "Sanction Token");
    }

    function test_TokenSymbol() public {
        assertEq(token.symbol(), "TKN");
    }

    function test_InitialSupply() public {
        assertEq(token.totalSupply(), 100_000);
    }

    function test_OwnerBalance() public {
        assertEq(token.balanceOf(owner), 100_000);
    }
}
