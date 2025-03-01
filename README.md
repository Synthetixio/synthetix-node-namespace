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
cast wallet import test-deployer --interactive
forge script ./script/deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --account test-deployer 
node codegen.js
```
