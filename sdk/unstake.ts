import type { Manager } from "../typechain-types/contracts";

export async function unstake(manager: Manager): Promise<void> {
  const tx = await manager.withdraw();
  await tx.wait();
}
