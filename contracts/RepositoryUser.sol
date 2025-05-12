// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IRepository} from "./Repository.sol";

/**
 * @title RepositoryUser
 * @dev The RepositoryUser contract is used to restrict access to the implementation contract.
 */
contract RepositoryUser {
    /**
     * @dev The repository contract.
     */
    IRepository public repository;

    /**
     * @dev Thrown when the caller is not the implementation contract.
     */
    error UnauthorizedRepoCall();

    /**
     * @dev Constructor.
     * @param _repository The address of the repository contract.
     */
    constructor(address _repository) {
        repository = IRepository(_repository);
    }

    /**
     * @dev Modifier to restrict access to the implementation contract.
     */
    modifier onlyImplementation() {
        if (msg.sender != repository.implementation()) {
            revert UnauthorizedRepoCall();
        }
        _;
    }
}
