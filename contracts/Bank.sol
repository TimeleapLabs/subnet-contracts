// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {RepositoryUser} from "./RepositoryUser.sol";

/**
 * @title Bank
 * @dev The Bank contract is used to manage staked tokens.
 */
contract Bank is RepositoryUser {
    using SafeERC20 for IERC20;

    /**
     * @dev Constructor.
     * @param _repository The address of the repository contract.
     */
    constructor(address _repository) RepositoryUser(_repository) {}

    /**
     * @dev Transfers tokens from the bank to a specified address.
     * @param token The address of the token contract.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     */
    function transfer(
        IERC20 token,
        address to,
        uint256 amount
    ) external onlyImplementation {
        token.safeTransfer(to, amount);
    }
}
