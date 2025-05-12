// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title Repository
 * @dev The Repository contract is used to store the address of the stake manager contract.
 * It is used to restrict access to the implementation contract.
 */
contract Repository is AccessControl, Context {
    address public implementation;

    event Upgraded(address indexed implementation);

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to set the address of the stake manager.
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Returns the address of the stake manager contract.
     * @param _implementation The address of the stake manager contract.
     */
    function upgrade(
        address _implementation
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        implementation = _implementation;
        emit Updated(_implementation);
    }
}

interface IRepository {
    function implementation() external view returns (address);

    function upgrade(address _implementation) external;
}
