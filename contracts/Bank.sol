// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {RepositoryUser} from "./RepositoryUser.sol";

/**
 * @title Bank
 * @dev The Bank contract is used to manage staked tokens.
 */
contract Bank is RepositoryUser, IERC721Receiver {
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

    /**
     * @dev Transfers ERC721 tokens from the bank to a specified address.
     * @param token The address of the ERC721 token contract.
     * @param to The address to transfer the token to.
     * @param tokenId The ID of the token to transfer.
     */
    function transferERC721(
        IERC721 token,
        address to,
        uint256 tokenId
    ) external onlyImplementation {
        IERC721(token).safeTransferFrom(address(this), to, tokenId);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override returns (bytes4) {
        // This function is required to accept ERC721 tokens.
        return this.onERC721Received.selector;
    }
}

interface IBank {
    function transfer(IERC20 token, address to, uint256 amount) external;

    function transferERC721(
        IERC721 token,
        address to,
        uint256 tokenId
    ) external;
}
