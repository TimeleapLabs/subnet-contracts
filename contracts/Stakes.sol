// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {RepositoryUser} from "./RepositoryUser.sol";

/**
 * @title Stakes
 * @dev The Stakes contract is used to keep track of staked tokens and their unlock dates.
 */
contract Stakes is RepositoryUser {
    mapping(address => uint256) stakeAmounts;
    mapping(address => uint256) satkedNfts;
    mapping(address => bool) hasNft;
    mapping(address => uint256) unlockDates;

    /**
     * @dev Constructor.
     * @param _repository The address of the repository contract.
     */
    constructor(address _repository) RepositoryUser(_repository) {}

    /**
     * @dev Throws if called by any account other than the implementation.
     * @notice This function is used to stake tokens.
     * @param user The address of the user to stake for.
     * @param amount The amount of tokens to stake.
     * @param duration The duration of the stake in seconds.
     */
    function stake(
        address user,
        uint256 amount,
        uint256 duration
    ) external onlyImplementation {
        stakeAmounts[user] += amount;
        unlockDates[user] = block.timestamp + duration;
    }

    function stakeWithNft(
        address user,
        uint256 amount,
        uint256 duration,
        uint256 nftId
    ) external onlyImplementation {
        stakeAmounts[user] += amount;
        satkedNfts[user] = nftId;
        hasNft[user] = true;
        unlockDates[user] = block.timestamp + duration;
    }

    /**
     * @dev Throws if called by any account other than the implementation.
     * @notice This function is used to withdraw staked tokens.
     * @param user The address of the user to withdraw for.
     */
    function withdraw(address user) external onlyImplementation {
        stakeAmounts[user] = 0;
        unlockDates[user] = 0;
        satkedNfts[user] = 0;
        hasNft[user] = false;
    }

    /**
     * @notice This function is used to get the amount of staked tokens for a user.
     * @param user The address of the user to get the stake amount for.
     * @return The amount of staked tokens for the user.
     */
    function getStakeAmount(address user) external view returns (uint256) {
        return stakeAmounts[user];
    }

    /**
     * @notice This function is used to get the staked NFT ID for a user.
     * @param user The address of the user to get the staked NFT ID for.
     * @return The staked NFT ID for the user.
     */
    function getStakedNftId(
        address user
    ) external view returns (bool, uint256) {
        return (hasNft[user], satkedNfts[user]);
    }

    /**
     * @notice This function is used to get the unlock date for a user.
     * @param user The address of the user to get the unlock date for.
     * @return The unlock date for the user.
     */
    function getUnlockDate(address user) external view returns (uint256) {
        return unlockDates[user];
    }
}

interface IStakes {
    function stake(uint256 amount, uint256 duration) external;

    function stakeWithNft(
        uint256 amount,
        uint256 duration,
        uint256 nftId
    ) external;

    function withdraw() external;

    function getStakeAmount(address user) external view returns (uint256);

    function getStakedNftId(address user) external view returns (bool, uint256);

    function getUnlockDate(address user) external view returns (uint256);
}
