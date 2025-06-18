export interface StakeParams {
  amount: bigint;
  duration: number;
}

export interface StakeWithNftParams extends StakeParams {
  nftId: bigint;
}

export interface LinkParams {
  /** arbitrary 32-byte identifier (e.g. sub-network ID) */
  to: string | Uint8Array; // bytes32
}
