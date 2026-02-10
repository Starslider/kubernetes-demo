"""Withdraw USDC from Polymarket wallet back to a target address."""

import json
import os
from web3 import Web3

POLYGON_RPC = "https://polygon-rpc.com"
USDC_ADDRESS = "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359"

ERC20_ABI = json.loads(
    '[{"inputs":[{"name":"to","type":"address"},{"name":"amount","type":"uint256"}],'
    '"name":"transfer","outputs":[{"name":"","type":"bool"}],'
    '"stateMutability":"nonpayable","type":"function"},'
    '{"inputs":[{"name":"account","type":"address"}],"name":"balanceOf",'
    '"outputs":[{"name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]'
)


def get_balances(w3: Web3, address: str) -> dict:
    """Get MATIC and USDC balances."""
    usdc = w3.eth.contract(address=Web3.to_checksum_address(USDC_ADDRESS), abi=ERC20_ABI)
    usdc_raw = usdc.functions.balanceOf(Web3.to_checksum_address(address)).call()
    matic_raw = w3.eth.get_balance(Web3.to_checksum_address(address))
    return {
        "matic": float(w3.from_wei(matic_raw, "ether")),
        "usdc": usdc_raw / 1e6,  # USDC has 6 decimals
        "usdc_raw": usdc_raw,
    }


def withdraw_usdc(destination: str, amount: float | None = None) -> dict:
    """Withdraw USDC to destination address.

    Args:
        destination: Target wallet address (0x...)
        amount: USDC amount to withdraw. None = withdraw all.

    Returns:
        Result dict with tx details.
    """
    private_key = os.environ["POLYMARKET_PRIVATE_KEY"]
    funder = os.environ["POLYMARKET_FUNDER_ADDRESS"]

    w3 = Web3(Web3.HTTPProvider(POLYGON_RPC))
    if not w3.is_connected():
        return {"status": "error", "message": "Cannot connect to Polygon RPC"}

    balances = get_balances(w3, funder)
    print(f"Wallet: {funder}")
    print(f"MATIC:  {balances['matic']:.4f}")
    print(f"USDC:   ${balances['usdc']:.2f}")

    if balances["usdc"] < 0.01:
        return {"status": "error", "message": "No USDC to withdraw"}

    if balances["matic"] < 0.005:
        return {"status": "error", "message": f"Insufficient MATIC for gas ({balances['matic']:.4f})"}

    if amount is None:
        send_raw = balances["usdc_raw"]
        send_amount = balances["usdc"]
    else:
        send_raw = int(amount * 1e6)
        send_amount = amount
        if send_raw > balances["usdc_raw"]:
            return {"status": "error", "message": f"Insufficient USDC (have ${balances['usdc']:.2f}, want ${amount:.2f})"}

    print(f"\nSending ${send_amount:.2f} USDC to {destination}...")

    usdc = w3.eth.contract(address=Web3.to_checksum_address(USDC_ADDRESS), abi=ERC20_ABI)
    nonce = w3.eth.get_transaction_count(Web3.to_checksum_address(funder))

    tx = usdc.functions.transfer(
        Web3.to_checksum_address(destination), send_raw
    ).build_transaction({
        "from": Web3.to_checksum_address(funder),
        "nonce": nonce,
        "gasPrice": w3.eth.gas_price,
        "chainId": 137,
    })

    signed = w3.eth.account.sign_transaction(tx, private_key)
    tx_hash = w3.eth.send_raw_transaction(signed.raw_transaction)
    print(f"TX: {tx_hash.hex()}")

    receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=120)
    success = receipt.status == 1

    new_balances = get_balances(w3, funder)
    print(f"\nRemaining: ${new_balances['usdc']:.2f} USDC, {new_balances['matic']:.4f} MATIC")

    return {
        "status": "success" if success else "failed",
        "tx_hash": tx_hash.hex(),
        "amount": send_amount,
        "destination": destination,
        "remaining_usdc": new_balances["usdc"],
        "remaining_matic": new_balances["matic"],
    }
