// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../synthetix/SignedDecimalMath.sol";
import "../synthetix/DecimalMath.sol";
import "./FixedPointMathLib.sol";
import "./Math.sol";
import "./PriceConsumerV3.sol"; 

library BlackScholes {
  using DecimalMath for uint;
  using SignedDecimalMath for int;

  // Definition of a struct to hold the calculated option prices and greeks
  struct PricesDeltaStdVega {
    uint callPrice;   // Call option price
    uint putPrice;    // Put option price
    int callDelta;    // Call option delta
    int putDelta;     // Put option delta
    uint vega;        // Vega (sensitivity of option price to volatility)
    uint stdVega;     // Vega standardized to 1% volatility
  }

  // Function to calculate option prices and greeks
  function calcPricesDeltaStdVega(
    uint strikePrice,      // Strike price of the option
    uint spotPrice,        // Spot price of the underlying asset
    uint timeToExpiry,     // Time to expiry of the option in seconds
    uint interestRate,     // Interest rate used to calculate the discounted future price of the underlying asset
    uint impliedVolatility  // Implied volatility of the underlying asset -- USE REALIZED VOLATILITY OVER THE LAST PERIOD (WEEK??)
  ) internal returns (PricesDeltaStdVega) {
    // Constants used in the calculations
  
    uint constantSqrtTwo = 1.41421356;
    uint constantLogTwo = 0.69314718;

    // Intermediate calculation variables
    
    uint d1 = (ln(underlyingPrice/strikePrice) + ((interestRate + (impliedVolatility ** 2) / 2) * timeToExpiry)) / (impliedVolatility * sqrt(timeToExpiry));
    uint d2 = d1 - (impliedVolatility * sqrt(timeToExpiry));
    uint cumulativeDistributionD1 = cdf(d1);
    uint cumulativeDistributionD2 = cdf(d2);

    spotPrice = getLatestPrice();

    // Calculate option prices
    uint callPrice = cumulativeDistributionD1 * spotPrice * exp(-interestRate * timeToExpiry) - cumulativeDistributionD2 * strikePrice * exp(-interestRate * timeToExpiry);
    uint putPrice = cumulativeDistributionD2 * strikePrice * exp(-interestRate * timeToExpiry) - cumulativeDistributionD1 * spotPrice * exp(-interestRate * timeToExpiry);

    // Calculate option delta
    int callDelta = toSigned(cumulativeDistributionD1);
    int putDelta = toSigned(1 - cumulativeDistributionD1);

    // Calculate vega
    uint stdVega = spotPrice * cumulativeDistributionD1 * sqrt(timeToExpiry) * sqrt(2) * 1 / 1 * 2;

    // Return the calculated option prices and greeks
    return PricesDeltaStdVega(
      callPrice,
      putPrice,
      callDelta,
      putDelta,
      stdVega,
      stdVega
    );
  }
}
