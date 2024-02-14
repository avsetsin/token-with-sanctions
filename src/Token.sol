// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SanctionList} from "./SanctionList.sol";

/**
 * @title Token Contract
 * @dev The contract implements a ERC20 token with a sanction list
 */
contract Token is SanctionList, ERC20 {
    event BurnedSanctionedFunds(address account, uint256 balance);

    error AccountNotUnderSanctions(address account);
    error AccountUnderSanctions(address account);

    /**
     * @dev Initializes the Token contract
     * @param owner The address that will initially own the token
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param initialSupply The initial supply of the token
     */
    constructor(address owner, string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
        Ownable(owner)
    {
        _mint(owner, initialSupply);
    }

    /**
     * @dev Burns the funds of a sanctioned account
     * Only the contract owner can call this function
     * @param account The address of the account whose funds will be burned
     * @dev Throws an error if the account is not under sanctions
     */
    function burnSanctionedFunds(address account) public onlyOwner {
        if (!isUnderSanctions[account]) revert AccountNotUnderSanctions(account);

        uint256 balanceToBurn = balanceOf(account);
        _burn(account, balanceToBurn);

        emit BurnedSanctionedFunds(account, balanceToBurn);
    }

    /**
     * @inheritdoc ERC20
     */
    function _update(address from, address to, uint256 value) internal override {
        if (isUnderSanctions[from] && to != address(0)) revert AccountUnderSanctions(from);
        if (isUnderSanctions[to]) revert AccountUnderSanctions(to);

        super._update(from, to, value);
    }
}
