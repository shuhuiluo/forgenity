# forgenity

This tool finds vanity addresses and their corresponding salts for contracts deployed via `CREATE2` in pure Solidity,
using [Forge](https://github.com/foundry-rs/foundry/tree/master/forge).

**Approximate Search Time**

| Leading Zeros | Time (s) | 
|---------------|----------|
| 3             | 1        |
| 4             | 16       |
| 5             | 256      |
| 6             | 4096     |

*The leading zeros are counted in hexadecimal. Therefore, the search time scales as 16^n.*

## Usage

To use, change `creationCode` and `encodeArguments()` according to your case in `Forgenity.t.sol`. Then, run:

```shell
forge test
```
