# Plugin: stocks

Display stock prices from Yahoo Finance.

## Screenshot

```
󰹨 AAPL $195.50 +1.25 GOOGL $142.30 -0.85
```

## Requirements

| Property | Value |
|----------|-------|
| Platform | macOS, Linux |
| Dependencies | `curl` |
| Content Type | dynamic |
| Presence | always |

## Quick Start

```bash
# Add to your tmux.conf
set -g @powerkit_plugins "stocks"
set -g @powerkit_plugin_stocks_tickers "AAPL,GOOGL"
```

## Configuration Example

```bash
set -g @powerkit_plugins "stocks"

# Stock tickers to track (comma-separated)
set -g @powerkit_plugin_stocks_tickers "AAPL,GOOGL,MSFT,TSLA"

# Display format: short or full
set -g @powerkit_plugin_stocks_format "short"

# Display options
set -g @powerkit_plugin_stocks_show_ticker "true"
set -g @powerkit_plugin_stocks_show_change "true"

# Separator between stocks
set -g @powerkit_plugin_stocks_separator " | "

# Icon
set -g @powerkit_plugin_stocks_icon "󰹨"

# Cache duration (5 minutes - respects API rate limits)
set -g @powerkit_plugin_stocks_cache_ttl "300"
```

## Options Reference

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `@powerkit_plugin_stocks_tickers` | string | `AAPL` | Stock tickers (comma-separated) |
| `@powerkit_plugin_stocks_format` | string | `short` | Display format: `short` or `full` |
| `@powerkit_plugin_stocks_show_ticker` | bool | `true` | Show stock ticker symbol in output |
| `@powerkit_plugin_stocks_show_change` | bool | `true` | Show price change with direction |
| `@powerkit_plugin_stocks_separator` | string | ` \| ` | Separator between stocks |
| `@powerkit_plugin_stocks_icon` | icon | `󰹨` | Plugin icon |
| `@powerkit_plugin_stocks_cache_ttl` | number | `300` | Cache duration in seconds |
| `@powerkit_plugin_stocks_show_only_on_threshold` | bool | `false` | Only show when threshold exceeded |

## States

| State | Condition |
|-------|-----------|
| `active` | Prices successfully retrieved |
| `degraded` | No tickers configured (needs setup) |
| `inactive` | No prices available |

## Health Levels

| Level | Condition |
|-------|-----------|
| `ok` | All stocks up or stable |
| `warning` | Any stock is down |
| `error` | No tickers configured |

## Context Values

| Context | Condition |
|---------|-----------|
| `up` | All stocks rising or stable |
| `down` | Some stocks declining |
| `unavailable` | No price data |
| `not_configured` | No tickers defined |

## Display Examples

**Short format (with ticker and change):**
```
󰹨 AAPL 195.50 ↑1.2% | GOOGL 142.30 ↓0.8%
```

**Full format (with $ sign):**
```
󰹨 AAPL $195.50 ↑1.2% | GOOGL $142.30 ↓0.8%
```

**Without ticker:**
```
󰹨 195.50 ↑1.2% | 142.30 ↓0.8%
```

**Without change:**
```
󰹨 AAPL 195.50 | GOOGL 142.30
```

**Single stock:**
```
󰹨 AAPL 195.50 ↑1.2%
```

## Common Stock Symbols

| Symbol | Company |
|--------|---------|
| `AAPL` | Apple Inc. |
| `GOOGL` | Alphabet Inc. |
| `MSFT` | Microsoft Corporation |
| `AMZN` | Amazon.com Inc. |
| `TSLA` | Tesla Inc. |
| `META` | Meta Platforms Inc. |
| `NVDA` | NVIDIA Corporation |
| `JPM` | JPMorgan Chase |
| `V` | Visa Inc. |
| `WMT` | Walmart Inc. |

## Data Source

Uses Yahoo Finance API:
- Endpoint: `https://query1.finance.yahoo.com/v8/finance/chart/{symbol}`
- Data: Real-time market price and daily change
- Rate limits: Reasonable for personal use with caching

## Market Hours

Stock prices update during market hours:
- **US Markets**: 9:30 AM - 4:00 PM ET (Mon-Fri)
- **Pre-market**: 4:00 AM - 9:30 AM ET
- **After-hours**: 4:00 PM - 8:00 PM ET

Outside market hours, the last closing price is shown.

## International Stocks

You can track international stocks using their full symbol:
- **London**: `HSBA.L` (HSBC)
- **Tokyo**: `7203.T` (Toyota)
- **Frankfurt**: `SAP.DE` (SAP)
- **Hong Kong**: `0700.HK` (Tencent)

## ETFs and Indices

Track ETFs and indices:
- `SPY` - S&P 500 ETF
- `QQQ` - Nasdaq 100 ETF
- `DIA` - Dow Jones ETF
- `^GSPC` - S&P 500 Index
- `^DJI` - Dow Jones Index
- `^IXIC` - Nasdaq Composite

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No prices shown | Check internet connection and symbol validity |
| Stale prices | Market may be closed; prices update during trading hours |
| Wrong price | Verify correct symbol (GOOGL vs GOOG) |
| API errors | Yahoo Finance may have temporary issues; increase `cache_ttl` |

## API Notes

- **No API key required** - Yahoo Finance is free for personal use
- **Caching recommended** - Default 5-minute cache reduces API calls
- **Rate limiting** - Excessive requests may be blocked

## Use Cases

### Portfolio Tracking
```bash
set -g @powerkit_plugin_stocks_tickers "AAPL,GOOGL,MSFT,AMZN"
```

### Index Watching
```bash
set -g @powerkit_plugin_stocks_tickers "SPY,QQQ,DIA"
```

### Single Stock Focus
```bash
set -g @powerkit_plugin_stocks_tickers "NVDA"
set -g @powerkit_plugin_stocks_show_change "true"
```

## Related Plugins

- [PluginCrypto](PluginCrypto) - Cryptocurrency prices
