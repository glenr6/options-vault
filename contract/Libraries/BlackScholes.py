import math
from scipy.stats import norm

def black_scholes(strike_price, spot_price, time_to_expiry, interest_rate, implied_volatility):
    # TO DO STILL:
        # connection to frontend listing page for user inputs
        #  chainlink price feed for spot price (coded, not implemented yet)
        #  testing of pricing with long tail values
        #  creating some sort of measure for Implied volatility (coding and implementing)

    

    # Intermediate calculation variables
    d1 = (math.log(spot_price/strike_price) + ((interest_rate + (implied_volatility ** 2) / 2) * time_to_expiry)) / (implied_volatility * math.sqrt(time_to_expiry))
    d2 = d1 - (implied_volatility * math.sqrt(time_to_expiry))
    cumulative_distribution_d1 = norm.cdf(d1)
    cumulative_distribution_d2 = norm.cdf(d2)

    # The spot price is not updated as per the getLatestPrice() method.
    
    # Calculate option prices
    call_price = cumulative_distribution_d1 * spot_price * math.exp(-interest_rate * time_to_expiry) - cumulative_distribution_d2 * strike_price * math.exp(-interest_rate * time_to_expiry)
    put_price = cumulative_distribution_d2 * strike_price * math.exp(-interest_rate * time_to_expiry) - cumulative_distribution_d1 * spot_price * math.exp(-interest_rate * time_to_expiry)

    # Calculate option delta
    call_delta = cumulative_distribution_d1
    put_delta = 1 - cumulative_distribution_d1

    # Calculate vega
    std_vega = spot_price * cumulative_distribution_d1 * math.sqrt(time_to_expiry) * math.sqrt(2) * 1 / 1 * 2

    # Return the calculated option prices and greeks
    return {
        'call_price': call_price,
        'put_price': put_price,
        'call_delta': call_delta,
        'put_delta': put_delta,
        'vega': std_vega,
        'std_vega': std_vega
    }

