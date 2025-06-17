// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title Linker
 * @dev The Linker contract is used to link users to their subnet identifiers.
 */
contract Linker is Context {
    mapping(address => bytes32) private links;

    event Linked(address indexed user, bytes32 link);

    /**
     * @dev Links a user to a specific identifier.
     * @param link The identifier to link the user to.
     */
    function link(bytes32 link) external {
        links[_msgSender()] = link;
        emit Linked(_msgSender(), link);
    }
}
