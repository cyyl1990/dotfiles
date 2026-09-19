# Plugin: crypto

Display cryptocurrency prices from CoinGecko API.

## Screenshot

```
 ₿42,150.00 | Ξ2,850.50
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | `curl` (required), `jq` (optional, better parsing) |
| Content Type | dynamic |
| Presence | conditional |

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "crypto"
```

## Configuration Example

```bash
set -g @powerkit_plugins "crypto"

# Coins to display (comma-separated symbols)
set -g @powerkit_plugin_crypto_coins "BTC,ETH,SOL"

# Currency for prices
set -g @powerkit_plugin_crypto_currency "USD"

# Format: full (42,150.00) or short (42.1k)
set -g @powerkit_plugin_crypto_format "full"

# Show 24h change percentage
set -g @powerkit_plugin_crypto_show_change "true"

# Separator between coins
set -g @powerkit_plugin_crypto_separator " | "

# Custom icon
set -g @powerkit_plugin_crypto_icon "󰠓"

# Cache duration (5 minutes default)
set -g @powerkit_plugin_crypto_cache_ttl "300"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_crypto_coins` | string | `BTC,ETH` | Crypto symbols (comma-separated) |
| `@powerkit_plugin_crypto_currency` | string | `USD` | Fiat currency for prices |
| `@powerkit_plugin_crypto_format` | string | `full` | Price format: `full` or `short` |
| `@powerkit_plugin_crypto_show_change` | bool | `true` | Show 24h price change percentage |
| `@powerkit_plugin_crypto_separator` | string | ` \| ` | Separator between coin prices |
| `@powerkit_plugin_crypto_icon` | icon | `󰠓` | Plugin icon |
| `@powerkit_plugin_crypto_cache_ttl` | number | `300` | Cache duration in seconds |
| `@powerkit_plugin_crypto_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## Supported Coins

| Symbol | Name | Display |
|--------|------|---------|
| `BTC` | Bitcoin | ₿ |
| `ETH` | Ethereum | Ξ |
| `SOL` | Solana | ◎ |
| `ADA` | Cardano | ADA |
| `DOT` | Polkadot | DOT |
| `DOGE` | Dogecoin | DOGE |
| `XRP` | Ripple | XRP |
| `LTC` | Litecoin | LTC |
| `LINK` | Chainlink | LINK |
| `MATIC` | Polygon | MATIC |
| `AVAX` | Avalanche | AVAX |
| `UNI` | Uniswap | UNI |
| `ATOM` | Cosmos | ATOM |
| `BNB` | Binance Coin | BNB |
| `USDT` | Tether | USDT |

## States

| State | Condition |
|-------|-----------|
| `active` | Prices successfully retrieved |
| `inactive` | No prices available (API error or empty response) |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | Always (price fluctuations don't affect health) |

## Context Values

| Context | Condition |
|---------|-----------|
| `available` | Prices are available |
| `unavailable` | No price data |

## Display Examples

**Full format:**
```
₿42,150.00 | Ξ2,850.50
```

**Short format:**
```
₿42.1k | Ξ2.8k
```

**With change:**
```
₿42,150.00 (+2.5%) | Ξ2,850.50 (-1.2%)
```

## Data Source

Uses [CoinGecko API](https://www.coingecko.com/api) (free, no API key required).

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No prices displayed | Check internet connection and `curl` availability |
| Stale prices | API might be rate-limited; increase `cache_ttl` |
| Unknown coin | Use standard symbols (BTC, ETH) or check CoinGecko for IDs |
| Wrong currency | Ensure currency code is valid (USD, EUR, GBP, etc.) |

## Related Plugins

- [PluginStocks](PluginStocks) - Stock market prices
