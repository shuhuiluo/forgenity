# forgenity

This tool finds vanity addresses and their corresponding salts for contracts deployed via `CREATE2` in pure Solidity,
using [Forge](https://github.com/foundry-rs/foundry/tree/master/forge).

Intuitively, the search time should scale as 16^n where n is the number of leading zeros in hexadecimal. However, using
Forge's fuzz input as salt and limiting the gas limit per run, the search time is much faster. While the optimal gas
limit per run with respect to the number of leading zeros is still unknown, some empirical results are shown below.

**Approximate Search Time**

| Leading Zeros | Time (s) | 
|---------------|----------|
| 3             | 1        |
| 4             | 16       |
| 5             | 226      |
| 6             | 1311     |
| 7             | 1683     |
| 8             | 4299     |

| Gas Per Run \ Leading Zeros | 4    | 5     | 6     | 7      | 8    |
|-----------------------------|------|-------|-------|--------|------|
| 1e5                         | 0.2  | 1.4   | 5.9   | 471.5  | 1450 |
| 1e6                         | 1.5  | 2.3   | 12.4  | 519.1  | 5545 |
| 1e7                         | 9.9  | 15.3  | 24.2  | 65.5   | 1123 |
| 1e8                         | 16.8 | 126.1 | 175.6 | 344.21 | 7400 |
| 1e9                         | 17.1 | 223   | 1382  | 1683   | 4299 |

## Usage

To use, change `creationCode` and `encodeArguments()` according to your case in `Forgenity.t.sol`. Then, run:

```shell
forge test --mt testVanity
```

To search in parallel, run:

```shell
python multicrunch.py
```
