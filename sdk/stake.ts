import type { Manager } from "../typechain-types/contracts";
import type { StakeParams, StakeWithNftParams } from "./types";

/**
 * Stake caller (tx signer) with an amount and duration.
 * Resolves once the tx is mined.
 */
export async function stake(
  manager: Manager,
  { amount, duration }: StakeParams
): Promise<void> {
  const tx = await manager.stake(amount, duration);
  await tx.wait();
}

/**
 * Stake caller (tx signer) with an amount, duration, and NFT ID.
 * Resolves once the tx is mined.
 */
export async function stakeWithNft(
  manager: Manager,
  { amount, duration, nftId }: StakeWithNftParams
): Promise<void> {
  const tx = await manager.stakeWithNft(amount, duration, nftId);
  await tx.wait();
}
