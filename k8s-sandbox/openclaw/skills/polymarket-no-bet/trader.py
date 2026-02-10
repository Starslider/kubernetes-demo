"""Polymarket trader — places NO bets via CLOB API."""

import json
import os
import time
from datetime import datetime, timezone, date
from pathlib import Path

from py_clob_client.client import ClobClient
from py_clob_client.clob_types import OrderArgs, OrderType
from py_clob_client.constants import POLYGON

STATE_DIR = Path(os.environ.get("OPENCLAW_STATE_DIR", "/home/node/.openclaw/polymarket"))
POSITIONS_FILE = STATE_DIR / "positions.json"
DAILY_SPEND_FILE = STATE_DIR / "daily_spend.json"
API_CREDS_FILE = STATE_DIR / "api_creds.json"

CLOB_HOST = "https://clob.polymarket.com"
CHAIN_ID = POLYGON


def _ensure_state_dir():
    STATE_DIR.mkdir(parents=True, exist_ok=True)


def _load_json(path: Path) -> dict:
    if path.exists():
        return json.loads(path.read_text())
    return {}


def _save_json(path: Path, data: dict):
    _ensure_state_dir()
    path.write_text(json.dumps(data, indent=2, default=str))


def get_daily_spend() -> float:
    """Get total spend for today."""
    data = _load_json(DAILY_SPEND_FILE)
    today = date.today().isoformat()
    return float(data.get(today, 0))


def record_spend(amount: float):
    """Record a spend for today."""
    data = _load_json(DAILY_SPEND_FILE)
    today = date.today().isoformat()
    data[today] = float(data.get(today, 0)) + amount
    # Clean up entries older than 30 days
    cutoff = date.today().isoformat()
    data = {k: v for k, v in data.items() if k >= cutoff[:8]}
    _save_json(DAILY_SPEND_FILE, data)


def get_positions() -> dict:
    """Load tracked positions."""
    return _load_json(POSITIONS_FILE)


def save_positions(positions: dict):
    """Save tracked positions."""
    _save_json(POSITIONS_FILE, positions)


def is_duplicate(condition_id: str) -> bool:
    """Check if we already have a position in this market."""
    positions = get_positions()
    return condition_id in positions


def get_open_position_count() -> int:
    """Count open (unresolved) positions."""
    positions = get_positions()
    return sum(1 for p in positions.values() if not p.get("resolved", False))


def _get_clob_client() -> ClobClient:
    """Initialize CLOB client with API credentials.

    On first run, derives L2 API credentials and caches them.
    """
    private_key = os.environ["POLYMARKET_PRIVATE_KEY"]
    funder = os.environ["POLYMARKET_FUNDER_ADDRESS"]

    creds = _load_json(API_CREDS_FILE)

    if creds:
        client = ClobClient(
            CLOB_HOST,
            key=private_key,
            chain_id=CHAIN_ID,
            funder=funder,
            creds={
                "apiKey": creds["apiKey"],
                "secret": creds["secret"],
                "passphrase": creds["passphrase"],
            },
        )
    else:
        client = ClobClient(
            CLOB_HOST,
            key=private_key,
            chain_id=CHAIN_ID,
            funder=funder,
        )
        derived = client.derive_api_key()
        creds = {
            "apiKey": derived.api_key,
            "secret": derived.secret,
            "passphrase": derived.passphrase,
        }
        _save_json(API_CREDS_FILE, creds)
        # Re-init with creds
        client = ClobClient(
            CLOB_HOST,
            key=private_key,
            chain_id=CHAIN_ID,
            funder=funder,
            creds=creds,
        )

    return client


def check_order_book(client: ClobClient, token_id: str) -> dict | None:
    """Check order book depth and spread for NO token.

    Returns best ask info or None if insufficient liquidity.
    """
    try:
        book = client.get_order_book(token_id)
    except Exception as e:
        print(f"  Error fetching order book: {e}")
        return None

    asks = book.asks if book.asks else []
    if not asks:
        return None

    best_ask = asks[0]
    best_price = float(best_ask.price)
    best_size = float(best_ask.size)

    if best_price > 0.12:
        return None

    if best_size < 100:
        return None

    # Check spread
    bids = book.bids if book.bids else []
    if bids:
        best_bid = float(bids[0].price)
        spread = best_price - best_bid
        if spread > 0.03:
            return None
    else:
        spread = best_price

    return {
        "best_ask": best_price,
        "best_ask_size": best_size,
        "spread": spread,
    }


def place_no_bet(
    candidate: dict,
    bet_size: float,
    dry_run: bool = True,
) -> dict:
    """Place a limit BUY order for NO shares.

    Returns trade result dict.
    """
    _ensure_state_dir()

    condition_id = candidate["condition_id"]
    no_token_id = candidate["no_token_id"]
    question = candidate["question"]

    result = {
        "market": question,
        "condition_id": condition_id,
        "no_token_id": no_token_id,
        "bet_size": bet_size,
        "dry_run": dry_run,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "status": "pending",
    }

    if dry_run:
        result["status"] = "dry_run"
        result["message"] = f"DRY RUN: Would buy ${bet_size:.2f} of NO @ ~${candidate['no_price']:.2f}"
        # Still record to positions for tracking
        positions = get_positions()
        positions[condition_id] = {
            "question": question,
            "no_token_id": no_token_id,
            "entry_price": candidate["no_price"],
            "bet_size": bet_size,
            "shares": 0,
            "order_id": "dry_run",
            "timestamp": result["timestamp"],
            "resolved": False,
            "dry_run": True,
        }
        save_positions(positions)
        return result

    try:
        client = _get_clob_client()

        book_info = check_order_book(client, no_token_id)
        if not book_info:
            result["status"] = "skipped"
            result["message"] = "Insufficient liquidity or spread too wide"
            return result

        price = book_info["best_ask"]
        shares = bet_size / price

        order_args = OrderArgs(
            price=price,
            size=shares,
            side="BUY",
            token_id=no_token_id,
        )
        signed_order = client.create_order(order_args)
        resp = client.post_order(signed_order, OrderType.GTC)

        order_id = resp.get("orderID", "unknown")
        result["status"] = "placed"
        result["order_id"] = order_id
        result["price"] = price
        result["shares"] = shares
        result["message"] = f"Placed BUY {shares:.1f} NO @ ${price:.3f} = ${bet_size:.2f}"

        # Record position
        positions = get_positions()
        positions[condition_id] = {
            "question": question,
            "no_token_id": no_token_id,
            "entry_price": price,
            "bet_size": bet_size,
            "shares": shares,
            "order_id": order_id,
            "timestamp": result["timestamp"],
            "resolved": False,
            "dry_run": False,
        }
        save_positions(positions)

        record_spend(bet_size)

    except Exception as e:
        result["status"] = "error"
        result["message"] = f"Order failed: {e}"

    return result


def execute_trades(
    candidates: list[dict],
    bet_size: float | None = None,
    daily_limit: float | None = None,
    max_positions: int | None = None,
    dry_run: bool = True,
) -> list[dict]:
    """Execute trades for a list of candidates with risk controls."""
    _ensure_state_dir()

    bet_size = bet_size or float(os.environ.get("POLYMARKET_BET_SIZE", "2"))
    daily_limit = daily_limit or float(os.environ.get("POLYMARKET_DAILY_LIMIT", "50"))
    max_positions = max_positions or int(os.environ.get("POLYMARKET_MAX_POSITIONS", "25"))

    current_spend = get_daily_spend()
    open_positions = get_open_position_count()
    results = []

    for candidate in candidates:
        # Daily limit check
        if current_spend + bet_size > daily_limit:
            results.append({
                "market": candidate["question"],
                "status": "skipped",
                "message": f"Daily limit reached (${current_spend:.2f}/${daily_limit:.2f})",
            })
            break

        # Max positions check
        if open_positions >= max_positions:
            results.append({
                "market": candidate["question"],
                "status": "skipped",
                "message": f"Max positions reached ({open_positions}/{max_positions})",
            })
            break

        # Duplicate check
        if is_duplicate(candidate["condition_id"]):
            results.append({
                "market": candidate["question"],
                "status": "skipped",
                "message": "Already have position in this market",
            })
            continue

        result = place_no_bet(candidate, bet_size, dry_run)
        results.append(result)

        if result["status"] in ("placed", "dry_run"):
            current_spend += bet_size
            open_positions += 1

        # Small delay between orders
        if not dry_run:
            time.sleep(1)

    return results


def format_status() -> str:
    """Format current status for display."""
    positions = get_positions()
    daily_spend = get_daily_spend()
    open_count = get_open_position_count()
    total = len(positions)

    lines = [
        f"Polymarket NO-Bet Status",
        f"{'=' * 40}",
        f"Daily spend: ${daily_spend:.2f} / ${os.environ.get('POLYMARKET_DAILY_LIMIT', '50')}",
        f"Open positions: {open_count} / {os.environ.get('POLYMARKET_MAX_POSITIONS', '25')}",
        f"Total positions (all time): {total}",
        f"Dry run: {os.environ.get('POLYMARKET_DRY_RUN', 'true')}",
        "",
    ]

    if positions:
        lines.append("Open positions:")
        for cid, pos in positions.items():
            if pos.get("resolved"):
                continue
            mode = " [DRY]" if pos.get("dry_run") else ""
            lines.append(
                f"  - {pos['question'][:60]}...\n"
                f"    Entry: ${pos['entry_price']:.3f} | Size: ${pos['bet_size']:.2f}{mode}"
            )

    return "\n".join(lines)
