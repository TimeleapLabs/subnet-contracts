import type { Manager } from "../typechain-types/contracts";
import type { StakeParams, StakeWithNftParams } from "./types";

export async function stake(
  manager: Manager,
  { amount, duration }: StakeParams
): Promise<void> {
  const tx = await manager.stake(amount, duration);
  await tx.wait();
}

export async function stakeWithNft(
  manager: Manager,
  { amount, duration, nftId }: StakeWithNftParams
): Promise<void> {
  const tx = await manager.stakeWithNft(amount, duration, nftId);
  await tx.wait();
}
