// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IStakes} from "./Stakes.sol";

/**
 * @title Linker
 * @dev The Linker contract is used to link users to their subnet identifiers.
 */
contract Linker is Context, AccessControl {
    mapping(address => bytes32) private links;
    mapping(bytes32 => address) private reverseLinks;

    event Linked(address indexed user, bytes32 link);

    error AlreadyLinked(address user, bytes32 link);
    error NoStake(address user);

    IStakes public stakes;

    constructor(IStakes _stakes) {
        stakes = _stakes;
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @dev Sets the stakes contract address.
     * @param _stakes The address of the stakes contract.
     */
    function setStakes(IStakes _stakes) external onlyRole(DEFAULT_ADMIN_ROLE) {
        stakes = _stakes;
    }

    /**
     * @dev Links a user to a specific identifier.
     * @param to The identifier to link the user to.
     */
    function link(bytes32 to) external {
        if (reverseLinks[to] != address(0)) {
            revert AlreadyLinked(_msgSender(), to);
        }

        uint256 userStake = stakes.getStakeAmount(_msgSender());
        (bool hasNft, ) = stakes.getStakedNftId(_msgSender());

        if (userStake == 0 && !hasNft) {
            revert NoStake(_msgSender());
        }

        links[_msgSender()] = to;
        reverseLinks[to] = _msgSender();
        emit Linked(_msgSender(), to);
    }

    /**
     * @dev Returns the identifier linked to a specific user address.
     * @param user The address of the user to look up.
     * @return The address of the user linked to the identifier.
     */
    function getLink(address user) external view returns (bytes32) {
        return links[user];
    }

    /**
     * @dev Returns the user address linked to a specific identifier.
     * @param to The identifier to look up.
     * @return The identifier linked to the user address.
     */
    function getUser(bytes32 to) external view returns (address) {
        return reverseLinks[to];
    }
}
