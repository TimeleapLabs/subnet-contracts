# 🕰️ Timeleap Subnet Staking Contracts

This repository contains the staking logic used in the **Timeleap Network**,
enabling participants to stake ERC-20 tokens with defined durations and
withdrawal conditions. The system is built with modularity and upgradeability in
mind, supporting safe and flexible future enhancements. Refer to
[TEP-5](https://timeleap.swiss/docs/tep/5) for more information.

## ⚙️ Architecture Overview

The staking system is composed of multiple contracts:

- **Manager**: Coordinates staking, slashing, and withdrawals.
- **Stakes**: Maintains stake records and lock durations.
- **Bank**: Handles token custody and transfers.
- **Repository**: Tracks the latest `Manager` contract deployed.

By distributing responsibilities across specialized contracts, the system
ensures that upgrades to logic can be performed safely without risking data or
funds.

## 🔁 Upgrade Pattern

The architecture follows a separation-of-concerns pattern to maximize safety and
flexibility:

- **Data and tokens are never stored in the Manager contract**. Instead, they
  are handled by dedicated contracts (`Stakes` and `Bank`) which remain
  untouched during logic upgrades.
- **The `Manager` contract contains only logic** and can be redeployed as needed
  to introduce new functionality or fix issues.
- **The `Repository` contract** serves as a pointer to the currently active
  Manager contract, allowing frontends and other contracts to reference the
  latest logic without requiring migrations or manual updates.

This pattern ensures that:

- User funds are always secure and unaffected by upgrades.
- Upgrades do not require interrupting the staking process.
- The system remains extensible and maintainable over time.

## 📦 Dependencies

- [OpenZeppelin Contracts v5.x](https://github.com/OpenZeppelin/openzeppelin-contracts)
- Solidity ^0.8.28

## 📄 License

This project is **UNLICENSED**. All rights reserved to Timeleap SA.
