"""Polymarket market scanner — finds high-probability NO-bet candidates."""

import json
import re
import httpx
from datetime import datetime, timezone, timedelta

GAMMA_API = "https://gamma-api.polymarket.com"

# Use word-boundary patterns to avoid false positives (e.g. "eth" in "Netherlands")
CRYPTO_PATTERNS = [
    re.compile(r"\bbitcoin\b", re.I),
    re.compile(r"\bbtc\b", re.I),
    re.compile(r"\bethereum\b", re.I),
    re.compile(r"\beth\b", re.I),
    re.compile(r"\bsolana\b", re.I),
    re.compile(r"\b\$sol\b", re.I),
    re.compile(r"\bcrypto\b", re.I),
    re.compile(r"\bcryptocurrency\b", re.I),
    re.compile(r"\bdogecoin\b", re.I),
    re.compile(r"\bdoge\b", re.I),
    re.compile(r"\bxrp\b", re.I),
    re.compile(r"\bcardano\b", re.I),
    re.compile(r"\bbnb\b", re.I),
    re.compile(r"\btoken price\b", re.I),
]


def fetch_active_markets(limit: int = 200) -> list[dict]:
    """Fetch active markets from Gamma API."""
    params = {
        "limit": limit,
        "active": "true",
        "closed": "false",
        "order": "volume24hr",
        "ascending": "false",
    }
    resp = httpx.get(f"{GAMMA_API}/markets", params=params, timeout=30)
    resp.raise_for_status()
    return resp.json()


def is_crypto_market(market: dict) -> bool:
    """Check if market is about crypto prices (too volatile for this strategy)."""
    text = market.get("question", "") + " " + market.get("description", "")
    return any(p.search(text) for p in CRYPTO_PATTERNS)


def parse_resolution_date(market: dict) -> datetime | None:
    """Parse the end date from market data."""
    end_str = market.get("endDate") or market.get("end_date_iso")
    if not end_str:
        return None
    try:
        if end_str.endswith("Z"):
            end_str = end_str[:-1] + "+00:00"
        return datetime.fromisoformat(end_str)
    except (ValueError, TypeError):
        return None


def scan_markets(
    min_yes_prob: float = 0.90,
    max_no_price: float = 0.12,
    min_volume: float = 10_000,
    max_days_to_resolution: int = 7,
) -> list[dict]:
    """Scan for NO-bet candidates matching our criteria.

    Returns list of candidate dicts with market info and trading params.
    """
    markets = fetch_active_markets()
    now = datetime.now(timezone.utc)
    max_end = now + timedelta(days=max_days_to_resolution)
    candidates = []

    for market in markets:
        if is_crypto_market(market):
            continue

        volume = float(market.get("volumeNum", 0) or market.get("volume", 0) or 0)
        if volume < min_volume:
            continue

        resolution_date = parse_resolution_date(market)
        if resolution_date is None or resolution_date > max_end:
            continue

        # Parse outcomes and prices from Gamma API format
        outcomes_raw = market.get("outcomes", "[]")
        prices_raw = market.get("outcomePrices", "[]")
        token_ids_raw = market.get("clobTokenIds", "[]")

        if isinstance(outcomes_raw, str):
            outcomes = json.loads(outcomes_raw)
        else:
            outcomes = outcomes_raw
        if isinstance(prices_raw, str):
            prices = json.loads(prices_raw)
        else:
            prices = prices_raw
        if isinstance(token_ids_raw, str):
            token_ids = json.loads(token_ids_raw)
        else:
            token_ids = token_ids_raw

        if len(outcomes) < 2 or len(prices) < 2 or len(token_ids) < 2:
            continue

        yes_idx = None
        no_idx = None
        for i, outcome in enumerate(outcomes):
            if outcome.lower() == "yes":
                yes_idx = i
            elif outcome.lower() == "no":
                no_idx = i

        if yes_idx is None or no_idx is None:
            continue

        yes_price = float(prices[yes_idx])
        no_price = float(prices[no_idx])

        if yes_price < min_yes_prob:
            continue

        if no_price > max_no_price:
            continue

        condition_id = market.get("conditionId", "")
        no_token_id = token_ids[no_idx]

        candidates.append({
            "market_id": market.get("id", ""),
            "condition_id": condition_id,
            "question": market.get("question", ""),
            "yes_price": yes_price,
            "no_price": no_price,
            "no_token_id": no_token_id,
            "volume": volume,
            "resolution_date": resolution_date.isoformat(),
            "days_to_resolution": (resolution_date - now).days,
            "slug": market.get("slug", ""),
        })

    candidates.sort(key=lambda c: c["yes_price"], reverse=True)
    return candidates


def format_candidates(candidates: list[dict]) -> str:
    """Format candidates for display."""
    if not candidates:
        return "No candidates found matching criteria."

    lines = [f"Found {len(candidates)} candidate(s):\n"]
    for i, c in enumerate(candidates, 1):
        lines.append(
            f"{i}. {c['question']}\n"
            f"   YES: ${c['yes_price']:.2f} | NO: ${c['no_price']:.2f} | "
            f"Vol: ${c['volume']:,.0f} | Resolves: {c['days_to_resolution']}d\n"
            f"   Token: {c['no_token_id'][:16]}..."
        )
    return "\n".join(lines)
