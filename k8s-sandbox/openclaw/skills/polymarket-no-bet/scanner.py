"""Polymarket market scanner — finds high-probability NO-bet candidates."""

import httpx
from datetime import datetime, timezone, timedelta

GAMMA_API = "https://gamma-api.polymarket.com"
CRYPTO_KEYWORDS = [
    "bitcoin", "btc", "ethereum", "eth", "solana", "sol", "crypto",
    "dogecoin", "doge", "xrp", "cardano", "ada", "bnb", "token price",
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
    question = (market.get("question", "") + " " + market.get("description", "")).lower()
    return any(kw in question for kw in CRYPTO_KEYWORDS)


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

        volume = float(market.get("volume", 0) or 0)
        if volume < min_volume:
            continue

        resolution_date = parse_resolution_date(market)
        if resolution_date is None or resolution_date > max_end:
            continue

        tokens = market.get("tokens", [])
        if not tokens or len(tokens) < 2:
            continue

        yes_token = None
        no_token = None
        for token in tokens:
            outcome = token.get("outcome", "").lower()
            if outcome == "yes":
                yes_token = token
            elif outcome == "no":
                no_token = token

        if not yes_token or not no_token:
            continue

        yes_price = float(yes_token.get("price", 0) or 0)
        no_price = float(no_token.get("price", 0) or 0)

        if yes_price < min_yes_prob:
            continue

        if no_price > max_no_price:
            continue

        condition_id = market.get("conditionId") or market.get("condition_id", "")
        no_token_id = no_token.get("token_id", "")

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
