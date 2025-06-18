import type { LinkParams } from "./types";
import type { Linker } from "../typechain-types";

/**
 * Link caller (tx signer) to an identifier.
 * Resolves once the tx is mined.
 */
export async function link(linker: Linker, { to }: LinkParams): Promise<void> {
  const tx = await linker.link(to);
  await tx.wait();
}

/** Read helper – returns bytes32(0) if none set. */
export async function getLink(linker: Linker, user: string): Promise<string> {
  return linker.getLink(user);
}

/** Reverse look-up helper – returns address(0) if none set. */
export async function getUser(
  linker: Linker,
  id: string | Uint8Array
): Promise<string> {
  return linker.getUser(id);
}
