// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Counter.sol";

contract Forgenity is Test {
    address internal constant factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    bytes32 internal constant initCodeHash = keccak256(type(Counter).creationCode);
    // The number of leading zeros in hex.
    uint256 internal constant leadingZeros = 5;

    error Found(bytes32 salt, address addr);

    function setUp() public {}

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

    /// @notice Get the mask to filter the leading zeros
    /// @param n The number of leading zeros in hex
    /// @return mask The mask to filter the leading zeros
    function leadingZerosMask(uint256 n) internal pure returns (uint256 mask) {
        assembly {
            mask := not(sub(shl(sub(256, shl(2, n)), 1), 1))
        }
    }

    function testVanity(bytes32 salt) public view {
        bytes32 _initCodeHash = initCodeHash;
        uint256 mask = leadingZerosMask(leadingZeros + 24);
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
                if iszero(and(res, mask)) { break }
            }
            // Restore the free memory pointer.
            mstore(0x40, fmp)
        }
        if (uint256(uint160(res)) & mask == 0) {
            revert Found(salt, res);
        } else {
            console.log("out of gas");
        }
    }
}
