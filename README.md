## Meritocratic voting

**OZ Governor and Tally work worth ERC20 (plutocratic voting - more tokens more vote weight) and ERC 721 (NFT - Yes or No voting). This project is asking the question of whether an NFT can be extended such that each NFT vote can have the weight between 0 and 1**

This project consists of an upgradable ERC721 contract:

- Each ERC721 token starts with a default weight of 0.2
- There's a tokenMultipliers mapping which contains many 'Multiplier's, which are structures which allows for any number of multipiers to applied to the ERC721's voting weight, to a maximum value of 1.

## Questions

Tally, and OZ Governor makes use the \_getVotingUnits function defined in ERC721VotesUpgradeable, how will it respond to a score between zero and 1, when counting votes.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
