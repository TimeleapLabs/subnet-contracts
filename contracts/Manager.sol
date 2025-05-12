// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IStakes} from "./Stakes.sol";
import {IBank} from "./Bank.sol";

MIN_STAKE_DURATION = 90 days;

/**
 * @title Manager
 * @dev The Manager contract is used to manage the stakes and bank contracts.
 */
contract Manager is AccessControl, Context {
    using SafeERC20 for IERC20;

    IStakes public stakes;
    IBank public bank;
    IERC20 public token;

    bytes32 public constant STAKE_MANAGER_ROLE =
        keccak256("STAKE_MANAGER_ROLE");

    event UpdatedStakes(address indexed stakes);
    event UpdatedBank(address indexed bank);
    event UpdatedToken(address indexed token);
    
    event Slashed(
        address indexed user,
        address indexed to,
        uint256 amount
    );

    event Withdrawn(
        address indexed user,
        uint256 amount
    );

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 duration
    );

    error MinStakeDurationNotMet();
    error NotUnlocked();

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to set the address of the stake manager.
     */
    constructor(IStakes _stakes, IBank _bank, IERC20 _token) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(STAKE_MANAGER_ROLE, _msgSender());
        stakes = _stakes;
        bank = _bank;
        token = _token;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to set the address of the stake manager.
     * @param _stakes The address of the stake manager contract.
     */
    function setStakes(IStakes _stakes) external onlyRole(DEFAULT_ADMIN_ROLE) {
        stakes = _stakes;
        emit UpdatedStakes(address(_stakes));
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to set the address of the bank contract.
     * @param _bank The address of the bank contract.
     */
    function setBank(IBank _bank) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bank = _bank;
        emit UpdatedBank(address(_bank));
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to set the address of the token contract.
     * @param _token The address of the token contract.
     */
    function setToken(IERC20 _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        token = _token;
        emit UpdatedToken(address(_token));
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to stake tokens.
     * @param user The address of the user to stake for.
     * @param amount The amount of tokens to stake.
     * @param duration The duration of the stake in seconds.
     */
    function stake(address user, uint256 amount, uint256 duration) external {
        if (duration < MIN_STAKE_DURATION) {
            revert MinStakeDurationNotMet();
        }

        token.safeTransferFrom(user, address(bank), amount);
        stakes.stake(user, amount, duration);

        emit Staked(user, amount, duration);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to withdraw staked tokens.
     * @param user The address of the user to withdraw for.
     */
    function withdraw(address user) external {
        uint256 unlockDate = stakes.getUnlockDate(user);
        if (block.timestamp < unlockDate) {
            revert NotUnlocked();
        }

        stakes.withdraw(user);
        bank.transfer(token, user, stakes.getStakeAmount(user));

        emit Withdrawn(user, stakes.getStakeAmount(user));
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to slash staked tokens.
     * @param user The address of the user to slash for.
     * @param to The address to transfer slashed tokens to.
     * @param amount The amount of tokens to slash.
     */
  function slash(
        address user,
        address to,
        uint256 amount,
    ) external onlyRole(STAKE_MANAGER_ROLE) {
        stakes.withdraw(user);
        bank.transfer(token, to, amount);

        emit Slashed(user, to, amount);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to get the amount of staked tokens for a user.
     * @param user The address of the user to get the stake amount for.
     * @return The amount of staked tokens for the user.
     */
    function getStakeAmount(address user) external view returns (uint256) {
        return stakes.getStakeAmount(user);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     * @notice This function is used to get the unlock date for a user.
     * @param user The address of the user to get the unlock date for.
     * @return The unlock date for the user.
     */
    function getUnlockDate(address user) external view returns (uint256) {
        return stakes.getUnlockDate(user);
    }
}
