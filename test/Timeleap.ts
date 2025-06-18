/*
  Unit tests for staking & withdrawing flows (with/without NFT)
  ------------------------------------------------------------
  • Framework: Hardhat (ethers v6) + Mocha + Chai
  • Contracts under test: Repository, Bank, Stakes, Manager, MockERC20, MockERC721
  • Scenarios:
      1. Stake ERC20 → success & MinStakeDurationNotMet revert
      2. Stake ERC20+NFT → success
      3. Withdraw before unlock → NotUnlocked revert
      4. Withdraw unlocked (ERC20 only) → success + event
      5. Withdraw unlocked (ERC20+NFT) → success + event & NFT returned
*/

import { ethers } from "hardhat";
import { expect } from "chai";
import {
  Bank,
  Stakes,
  Repository,
  Manager,
  MockERC20,
  MockERC721,
} from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

const DAY = 24 * 60 * 60;
const MIN_STAKE_DURATION = 90 * DAY;

async function increaseTime(seconds: number) {
  await ethers.provider.send("evm_increaseTime", [seconds]);
  await ethers.provider.send("evm_mine", []);
}

describe("Manager – staking flow", function () {
  let deployer: HardhatEthersSigner;
  let user: HardhatEthersSigner;

  let repo: Repository;
  let bank: Bank;
  let stakes: Stakes;
  let manager: Manager;
  let token: MockERC20;
  let nft: MockERC721;

  beforeEach(async () => {
    [deployer, user] = await ethers.getSigners();

    // ───── Deploy infra ──────────────────────────────────────────────
    repo = await (await ethers.getContractFactory("Repository")).deploy();

    bank = await (await ethers.getContractFactory("Bank")).deploy(repo.target);
    stakes = await (
      await ethers.getContractFactory("Stakes")
    ).deploy(repo.target);

    token = await (
      await ethers.getContractFactory("MockERC20")
    ).deploy("Token", "TKN");
    nft = await (
      await ethers.getContractFactory("MockERC721")
    ).deploy("NFT", "NFT");

    manager = await (
      await ethers.getContractFactory("Manager")
    ).deploy(stakes.target, bank.target, token.target, nft.target);

    // Register Manager as implementation so Bank & Stakes accept calls
    await repo.upgrade(manager.target);

    // Fund user with assets
    await token.mint(await user.getAddress(), ethers.parseEther("1000"));
    await nft.mint(await user.getAddress()); // tokenId 0
  });

  // ──────────────────────────────────────────────────────────────────
  describe("stake()", () => {
    it("reverts when duration < MIN_STAKE_DURATION", async () => {
      const amount = ethers.parseEther("10");
      await token.connect(user).approve(manager.target, amount);

      await expect(
        manager
          .connect(deployer)
          .stake(await user.getAddress(), amount, MIN_STAKE_DURATION - 1)
      ).to.be.revertedWithCustomError(manager, "MinStakeDurationNotMet");
    });

    it("stakes ERC20 correctly", async () => {
      const amount = ethers.parseEther("50");
      const duration = MIN_STAKE_DURATION + DAY;

      await token.connect(user).approve(manager.target, amount);

      await expect(
        manager
          .connect(deployer)
          .stake(await user.getAddress(), amount, duration)
      )
        .to.emit(manager, "Staked")
        .withArgs(await user.getAddress(), amount, duration);

      expect(await token.balanceOf(bank.target)).to.equal(amount);
      expect(await stakes.getStakeAmount(await user.getAddress())).to.equal(
        amount
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────
  describe("stakeWithNft()", () => {
    it("stakes ERC20 + NFT correctly", async () => {
      const amount = ethers.parseEther("20");
      const duration = MIN_STAKE_DURATION + 2 * DAY;
      const nftId = 0;

      await token.connect(user).approve(manager.target, amount);
      await nft.connect(user).approve(manager.target, nftId);

      await expect(
        manager
          .connect(deployer)
          .stakeWithNft(await user.getAddress(), amount, duration, nftId)
      )
        .to.emit(manager, "StakedWithNft")
        .withArgs(await user.getAddress(), amount, duration, nftId);

      expect(await token.balanceOf(bank.target)).to.equal(amount);
      expect(await nft.ownerOf(nftId)).to.equal(bank.target);
      const [, storedId] = await stakes.getStakedNftId(await user.getAddress());
      expect(storedId).to.equal(nftId);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  describe("withdraw()", () => {
    it("reverts if unlock date not reached", async () => {
      const amount = ethers.parseEther("5");
      await token.connect(user).approve(manager.target, amount);
      await manager
        .connect(deployer)
        .stake(await user.getAddress(), amount, MIN_STAKE_DURATION + DAY);

      await expect(
        manager.connect(deployer).withdraw(await user.getAddress())
      ).to.be.revertedWithCustomError(manager, "NotUnlocked");
    });

    it("withdraws ERC20 when unlocked", async () => {
      const amount = ethers.parseEther("15");
      await token.connect(user).approve(manager.target, amount);
      await manager
        .connect(deployer)
        .stake(await user.getAddress(), amount, MIN_STAKE_DURATION);

      await increaseTime(MIN_STAKE_DURATION + 1);

      await expect(manager.connect(deployer).withdraw(await user.getAddress()))
        .to.emit(manager, "Withdrawn")
        .withArgs(await user.getAddress(), amount);

      expect(await token.balanceOf(bank.target)).to.equal(0);
      expect(await stakes.getStakeAmount(await user.getAddress())).to.equal(0);
    });

    it("withdraws ERC20 + NFT when unlocked", async () => {
      const amount = ethers.parseEther("25");
      const nftId = 0;

      await token.connect(user).approve(manager.target, amount);
      await nft.connect(user).approve(manager.target, nftId);

      await manager
        .connect(deployer)
        .stakeWithNft(
          await user.getAddress(),
          amount,
          MIN_STAKE_DURATION,
          nftId
        );

      await increaseTime(MIN_STAKE_DURATION + 1);

      await expect(manager.connect(deployer).withdraw(await user.getAddress()))
        .to.emit(manager, "WithdrawnWithNft")
        .withArgs(await user.getAddress(), amount, nftId);

      expect(await nft.ownerOf(nftId)).to.equal(await user.getAddress());
      expect(await token.balanceOf(bank.target)).to.equal(0);
    });
  });
});
