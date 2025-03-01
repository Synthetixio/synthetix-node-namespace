## Usage

### Build

```sh
forge build
```

### Test

```sh
forge test
```

### Format

```sh
forge fmt
```

### Gas Snapshots

```sh
forge snapshot
```

### Anvil

```sh
anvil
```

### Deploy

```sh
cast wallet import snx-testnet --interactive

_sender="$(cast wallet address --account snx-testnet)"

forge script ./script/deploy.s.sol \
  --rpc-url $RPC_OPTIMISM_SEPOLIA \
  --account snx-testnet \
  --sender "$_sender"

forge script ./script/deploy.s.sol \
  --rpc-url $RPC_OPTIMISM_SEPOLIA \
  --broadcast \
  --account snx-testnet \
  --sender "$_sender"\
  --etherscan-api-key $OPTIMISTIC_ETHERSCAN_API_KEY \
  --verify

node codegen.js
```
