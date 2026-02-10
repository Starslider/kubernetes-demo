# Polymarket NO-Bet Strategy

Automated scanner and trader for Polymarket prediction markets. Finds markets where YES is trading above 90% and places small NO bets to profit from near-certain outcomes.

## Cron

```
*/30 * * * *
```

## Commands

- `scan` — List candidate markets (read-only, no auth needed)
- `trade` — Scan markets and place NO bets (respects POLYMARKET_DRY_RUN)
- `status` — Show open positions and daily spend

## Usage

```bash
cd /home/node/.openclaw/skills/polymarket-no-bet
python3 main.py scan
python3 main.py trade
python3 main.py status
```

## Required Environment Variables

| Variable | Source | Description |
|----------|--------|-------------|
| `POLYMARKET_PRIVATE_KEY` | Secret | Wallet private key (0x...) |
| `POLYMARKET_FUNDER_ADDRESS` | Secret | Wallet address (0x...) |
| `POLYMARKET_TELEGRAM_CHAT_ID` | Secret | Telegram chat ID for notifications |
| `TELEGRAM_TOKEN` | Secret | Telegram bot token (shared with OpenClaw) |
| `POLYMARKET_DRY_RUN` | ConfigMap | `true` (default) or `false` |
| `POLYMARKET_BET_SIZE` | ConfigMap | Dollars per bet (default: 2) |
| `POLYMARKET_DAILY_LIMIT` | ConfigMap | Max daily spend (default: 50) |
| `POLYMARKET_MAX_POSITIONS` | ConfigMap | Max open positions (default: 25) |
| `PYTHONPATH` | ConfigMap | Python packages path |

## Setup

1. Install dependencies on pod:
   ```bash
   pip3 install --target /home/node/.openclaw/python-packages py-clob-client httpx web3
   ```

2. Run one-time token approvals (requires MATIC for gas):
   ```bash
   python3 allowances.py
   ```

3. Test scanner:
   ```bash
   python3 main.py scan
   ```

4. Set `POLYMARKET_DRY_RUN=false` to enable live trading.

## Strategy

- **Filter**: YES > 90%, NO < $0.12, volume > $10k, resolves within 7 days
- **Skip**: Crypto price markets (too volatile)
- **Sizing**: $2/bet default, $50/day max, 25 max positions
- **Orders**: Limit BUY on NO side at best ask or slightly below
- **State**: Positions tracked in `/home/node/.openclaw/polymarket/positions.json`
