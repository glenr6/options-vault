pragma solidity 0.8.16;

// @dev Library to unify logic for common shared functions
 
library Math {
  function min(uint x, uint y) internal pure returns (uint) {
    return (x < y) ? x : y;
  }

  function max(uint x, uint y) internal pure returns (uint) {
    return (x > y) ? x : y;
  }

  function abs(int val) internal pure returns (uint) {
    return uint(val < 0 ? -val : val);
  }

  /// @dev Takes ceiling of a to m precision
  /// @param m represents 1eX where X is the number of trailing 0's
  function ceil(uint a, uint m) internal pure returns (uint) {
    return ((a + m - 1) / m) * m;
  }
}