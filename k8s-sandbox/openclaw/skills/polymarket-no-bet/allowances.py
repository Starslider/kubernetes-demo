#!/usr/bin/env python3
"""One-time token approval for Polymarket exchange contracts.

Run once to approve USDC and CTF tokens for trading.
Requires small MATIC balance for gas fees.

Usage:
    python3 allowances.py
"""

import os
import json
import time
from web3 import Web3

# Polygon mainnet
POLYGON_RPC = "https://polygon-rpc.com"

# Polymarket contract addresses on Polygon
USDC_ADDRESS = "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359"
CTF_ADDRESS = "0x4D97DCd97eC945f40cF65F87097ACe5EA0476045"
EXCHANGE_ADDRESS = "0x4bFb41d5B3570DeFd03C39a9A4D8dE6Bd8B8982E"
NEG_RISK_EXCHANGE_ADDRESS = "0xC5d563A36AE78145C45a50134d48A1215220f80a"
NEG_RISK_ADAPTER_ADDRESS = "0xd91E80cF2E7be2e162c6513ceD06f1dD0dA35296"

MAX_APPROVAL = 2**256 - 1

# ERC-20 approve ABI
ERC20_ABI = json.loads('[{"inputs":[{"name":"spender","type":"address"},{"name":"amount","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]')

# ERC-1155 setApprovalForAll ABI
ERC1155_ABI = json.loads('[{"inputs":[{"name":"operator","type":"address"},{"name":"approved","type":"bool"}],"name":"setApprovalForAll","outputs":[],"stateMutability":"nonpayable","type":"function"}]')


def wait_for_receipt(w3: Web3, tx_hash, timeout: int = 180, poll_interval: int = 15):
    """Wait for transaction receipt with retry on rate limits."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            receipt = w3.eth.get_transaction_receipt(tx_hash)
            if receipt is not None:
                return receipt
        except Exception:
            pass
        time.sleep(poll_interval)
    raise TimeoutError(f"TX {tx_hash.hex()} not confirmed within {timeout}s")


def approve_all():
    """Run all necessary token approvals."""
    private_key = os.environ["POLYMARKET_PRIVATE_KEY"]
    funder = os.environ["POLYMARKET_FUNDER_ADDRESS"]

    w3 = Web3(Web3.HTTPProvider(POLYGON_RPC))
    if not w3.is_connected():
        print("ERROR: Cannot connect to Polygon RPC")
        return

    balance = w3.eth.get_balance(funder)
    matic = w3.from_wei(balance, "ether")
    print(f"Wallet: {funder}")
    print(f"MATIC balance: {matic:.4f}")

    if matic < 0.01:
        print("ERROR: Insufficient MATIC for gas. Need at least 0.01 MATIC.")
        return

    nonce = w3.eth.get_transaction_count(funder)

    # USDC approvals
    usdc = w3.eth.contract(address=Web3.to_checksum_address(USDC_ADDRESS), abi=ERC20_ABI)
    spenders = [
        ("Exchange", EXCHANGE_ADDRESS),
        ("NegRiskExchange", NEG_RISK_EXCHANGE_ADDRESS),
        ("NegRiskAdapter", NEG_RISK_ADAPTER_ADDRESS),
    ]

    for name, spender in spenders:
        print(f"\nApproving USDC for {name}...")
        time.sleep(10)
        tx = usdc.functions.approve(
            Web3.to_checksum_address(spender), MAX_APPROVAL
        ).build_transaction({
            "from": funder,
            "nonce": nonce,
            "gasPrice": w3.eth.gas_price,
            "chainId": 137,
        })
        signed = w3.eth.account.sign_transaction(tx, private_key)
        tx_hash = w3.eth.send_raw_transaction(signed.raw_transaction)
        print(f"  TX: {tx_hash.hex()}")
        receipt = wait_for_receipt(w3, tx_hash)
        print(f"  Status: {'OK' if receipt.status == 1 else 'FAILED'}")
        nonce += 1

    # CTF (ERC-1155) approvals
    ctf = w3.eth.contract(address=Web3.to_checksum_address(CTF_ADDRESS), abi=ERC1155_ABI)

    for name, operator in spenders:
        print(f"\nApproving CTF for {name}...")
        time.sleep(10)
        tx = ctf.functions.setApprovalForAll(
            Web3.to_checksum_address(operator), True
        ).build_transaction({
            "from": funder,
            "nonce": nonce,
            "gasPrice": w3.eth.gas_price,
            "chainId": 137,
        })
        signed = w3.eth.account.sign_transaction(tx, private_key)
        tx_hash = w3.eth.send_raw_transaction(signed.raw_transaction)
        print(f"  TX: {tx_hash.hex()}")
        receipt = wait_for_receipt(w3, tx_hash)
        print(f"  Status: {'OK' if receipt.status == 1 else 'FAILED'}")
        nonce += 1

    print("\nAll approvals complete!")


if __name__ == "__main__":
    approve_all()
