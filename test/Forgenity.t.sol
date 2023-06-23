// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract Forgenity is Test {
    // https://github.com/pcaversaccio/create2deployer
    address internal constant factory = 0x13b0D85CcB8bf860b6b79AF3029fCA081AE9beF2;
    bytes32 internal initCodeHash;
    // The number of leading zeros in hex.
    uint256 internal constant leadingZeros = 4;

    // emitted when a vanity address is found
    error Found(bytes32 salt, address addr);
    // emitted when the deployment fails
    error DeploymentFailed();

    function setUp() public {
        bytes memory initCode = bytes.concat(type(Counter).creationCode, encodeArguments());
        initCodeHash = keccak256(initCode);
        // check that the init code works
        address addr;
        assembly ("memory-safe") {
            addr := create2(0, add(initCode, 0x20), mload(initCode), 0)
        }
        if (addr != computeCreate2Address(address(this), 0, initCodeHash)) {
            revert DeploymentFailed();
        }
    }

    function encodeArguments() internal pure returns (bytes memory) {
        return abi.encode(0);
    }

    /// @notice Efficiently computes the CREATE2 address
    function computeCreate2Address(address _factory, bytes32 salt, bytes32 _initCodeHash)
        internal
        pure
        returns (address res)
    {
        assembly ("memory-safe") {
            // Cache the free memory pointer.
            let fmp := mload(0x40)
            // abi.encodePacked(hex'ff', factory, salt, initCodeHash)
            // Prefix the factory address with 0xff.
            mstore(0, or(_factory, 0xff0000000000000000000000000000000000000000))
            mstore(0x20, salt)
            mstore(0x40, _initCodeHash)
            // Compute the CREATE2 address and clean the upper bits.
            res := and(keccak256(0x0b, 0x55), 0xffffffffffffffffffffffffffffffffffffffff)
            // Restore the free memory pointer.
            mstore(0x40, fmp)
        }
    }

    function testVanity(bytes32 salt) public view {
        bytes32 _initCodeHash = initCodeHash;
        uint256 nonzeroBits = 160 - leadingZeros * 4;
        address res;
        assembly ("memory-safe") {
            // Cache the free memory pointer.
            let fmp := mload(0x40)
            // abi.encodePacked(hex'ff', factory, salt, initCodeHash)
            // Prefix the factory address with 0xff.
            mstore(0, or(factory, 0xff0000000000000000000000000000000000000000))
            mstore(0x40, _initCodeHash)
            for {} lt(gas(), 9223372036854770000) { salt := add(salt, 1) } {
                mstore(0x20, salt)
                // Compute the CREATE2 address and clean the upper 96 bits.
                res := and(keccak256(0x0b, 0x55), 0xffffffffffffffffffffffffffffffffffffffff)
                if iszero(shr(nonzeroBits, res)) { break }
            }
            // Restore the free memory pointer.
            mstore(0x40, fmp)
        }
        if (uint256(uint160(res)) >> nonzeroBits == 0) {
            revert Found(salt, res);
        } else {
            console.log("out of gas");
        }
    }
}
