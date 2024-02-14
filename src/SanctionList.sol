// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @title SanctionList
 * @dev A contract that implements a sanction list
 */
abstract contract SanctionList is Ownable2Step {
    mapping(address => bool) public isUnderSanctions;

    event AddedToSanctionList(address account);
    event RemovedFromSanctionList(address account);

    /**
     * @dev Adds an account to the sanction list
     * Only the contract owner can call this function
     * @param account The address of the account to be added to the sanction list
     */
    function addToSanctionList(address account) public onlyOwner {
        isUnderSanctions[account] = true;
        emit AddedToSanctionList(account);
    }

    /**
     * @dev Removes an account from the sanction list
     * Only the contract owner can call this function
     * @param account The address of the account to be removed from the sanction list
     */
    function removeFromSanctionList(address account) public onlyOwner {
        isUnderSanctions[account] = false;
        emit RemovedFromSanctionList(account);
    }
}
