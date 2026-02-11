#!/usr/bin/env python3
"""Polymarket NO-Bet Strategy — main entry point.

Usage:
    python3 main.py scan                        — List candidate markets (read-only)
    python3 main.py trade                       — Scan + place bets (respects dry-run)
    python3 main.py status                      — Show positions and daily spend
    python3 main.py withdraw 0xDestination      — Withdraw all USDC to address
    python3 main.py withdraw 0xDestination 50   — Withdraw $50 USDC to address
    python3 main.py balance                     — Show wallet balances
"""

import os
import sys
import httpx

from scanner import scan_markets, format_candidates
from trader import execute_trades, format_status
from withdraw import withdraw_usdc, get_balances


def send_telegram(message: str):
    """Send notification via Telegram."""
    token = os.environ.get("TELEGRAM_TOKEN")
    chat_id = os.environ.get("POLYMARKET_TELEGRAM_CHAT_ID")

    if not token or not chat_id:
        print("Telegram not configured, skipping notification")
        return

    try:
        url = f"https://api.telegram.org/bot{token}/sendMessage"
        resp = httpx.post(
            url,
            json={
                "chat_id": chat_id,
                "text": message,
                "parse_mode": "HTML",
                "disable_web_page_preview": True,
            },
            timeout=10,
        )
        resp.raise_for_status()
    except Exception as e:
        print(f"Telegram notification failed: {e}")


def cmd_scan():
    """Scan for candidate markets."""
    print("Scanning Polymarket for NO-bet candidates...\n")
    candidates = scan_markets()
    output = format_candidates(candidates)
    print(output)
    return candidates


def cmd_trade():
    """Scan and execute trades."""
    dry_run = os.environ.get("POLYMARKET_DRY_RUN", "true").lower() == "true"
    mode = "DRY RUN" if dry_run else "LIVE"

    print(f"Polymarket NO-Bet Trader ({mode})\n")

    candidates = scan_markets()
    if not candidates:
        msg = "No candidates found matching criteria."
        print(msg)
        send_telegram(f"🔍 Polymarket Scan: {msg}")
        return

    print(format_candidates(candidates))
    print(f"\nExecuting trades ({mode})...\n")

    results = execute_trades(candidates, dry_run=dry_run)

    # Format results
    lines = [f"<b>Polymarket NO-Bet ({mode})</b>\n"]
    for r in results:
        status_icon = {
            "placed": "✅",
            "dry_run": "🔸",
            "skipped": "⏭",
            "error": "❌",
        }.get(r["status"], "❓")

        market_short = r["market"][:50]
        lines.append(f"{status_icon} {market_short}\n   {r.get('message', r['status'])}")

    output = "\n".join(lines)
    print(output)
    send_telegram(output)


def cmd_status():
    """Show current status."""
    output = format_status()
    print(output)


def cmd_balance():
    """Show wallet balances."""
    from web3 import Web3
    funder = os.environ["POLYMARKET_FUNDER_ADDRESS"]
    w3 = Web3(Web3.HTTPProvider("https://polygon-rpc.com"))
    balances = get_balances(w3, funder)
    print(f"Wallet:  {funder}")
    print(f"MATIC:   {balances['matic']:.4f}")
    print(f"USDC:    ${balances['usdc']:.2f}")
    print(f"USDC.e:  ${balances['usdc_e']:.2f}  (Polymarket)")


def cmd_withdraw():
    """Withdraw USDC to a destination address."""
    if len(sys.argv) < 3:
        print("Usage: python3 main.py withdraw 0xDestination [amount]")
        sys.exit(1)

    destination = sys.argv[2]
    amount = float(sys.argv[3]) if len(sys.argv) > 3 else None
    label = f"${amount:.2f}" if amount else "all"

    result = withdraw_usdc(destination, amount)

    if result["status"] == "success":
        msg = (
            f"<b>Polymarket Withdrawal</b>\n"
            f"Sent ${result['amount']:.2f} USDC to {destination[:10]}...\n"
            f"TX: {result['tx_hash']}\n"
            f"Remaining: ${result['remaining_usdc']:.2f} USDC"
        )
        print(f"\nSuccess! TX: {result['tx_hash']}")
    else:
        msg = f"<b>Polymarket Withdrawal Failed</b>\n{result['message']}"
        print(f"\nFailed: {result['message']}")

    send_telegram(msg)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1].lower()
    commands = {
        "scan": cmd_scan,
        "trade": cmd_trade,
        "status": cmd_status,
        "withdraw": cmd_withdraw,
        "balance": cmd_balance,
    }

    if command not in commands:
        print(f"Unknown command: {command}")
        print(f"Available: {', '.join(commands)}")
        sys.exit(1)

    commands[command]()


if __name__ == "__main__":
    main()
