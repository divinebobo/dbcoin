# dbcoin

A simple fungible token smart contract written in [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-language), managed with [Clarinet](https://docs.hiro.so/clarinet/introduction).

This project defines a minimal Dbcoin (symbol: `DB`) token with:

- One-time initialization to mint an initial supply
- Balance tracking per principal
- Token transfers between principals

---

## Project layout

- `Clarinet.toml` – Clarinet project configuration pointing to the `dbcoin` contract
- `contracts/dbcoin.clar` – Dbcoin token contract implementation

You can add tests, additional contracts, or deployment configuration using the Clarinet CLI.

---

## Prerequisites

- **Clarinet** (already installed on this machine)
- Node.js (optional, if you want to integrate with tools around Clarinet)

To confirm Clarinet is installed:

```powershell
clarinet --version
```

---

## Using the dbcoin contract

### Key functions

Contract: `contracts/dbcoin.clar`

**Metadata**

- `get-name () -> (response (string-ascii 32) uint)`  
  Returns the token name, e.g. `"dbcoin"`.

- `get-symbol () -> (response (string-ascii 8) uint)`  
  Returns the token ticker symbol, `"DB"`.

- `get-decimals () -> (response uint uint)`  
  Returns the number of decimals (here `u6`). A balance of `u1000000` represents `1.000000 DB`.

**Supply & balances**

- `get-total-supply () -> (response uint uint)`  
  Returns the total number of `DB` tokens that exist.

- `get-balance-of (account principal) -> (response uint uint)`  
  Returns the balance of a specific principal. If the account has no tokens yet, returns `u0`.

**State-changing functions**

- `initialize (recipient principal) (amount uint) -> (response bool uint)`  
  Mints an initial supply of `amount` tokens to `recipient`.
  - Can only be called **once** for the lifetime of the contract.
  - If called again, it returns error `u101`.

- `transfer (amount uint) (sender principal) (recipient principal) -> (response bool uint)`  
  Transfers `amount` tokens from `sender` to `recipient`.
  - The transaction sender (`tx-sender`) must equal `sender`, otherwise returns error `u100`.
  - If `sender` does not have enough balance, returns error `u102`.

**Error codes**

- `u100` – not authorized (e.g. `tx-sender` is not the declared `sender` in `transfer`)
- `u101` – token has already been initialized
- `u102` – insufficient balance for transfer

---

## Running Clarinet commands

All commands below assume your working directory is the project root:

```powershell
cd "C:\Users\NKECHI OKOYE\Documents\GitHub\dbcoin"
```

### Check contracts

Use `clarinet check` to verify that the contract parses and type-checks correctly:

```powershell
clarinet check
```

This reads `Clarinet.toml` and checks the `contracts/dbcoin.clar` contract listed there.

### Console (optional)

You can experiment with the contract in a Clarinet console REPL:

```powershell
clarinet console
```

From the console you can call functions like:

```scheme
(contract-call? .dbcoin initialize 'ST2J8EVYHP9MB9XMB6FX6AVZ8E9FJ9X3R2RZ6Q4Y u1000000)
(contract-call? .dbcoin transfer u500000 'ST2J8EVYHP9MB9XMB6FX6AVZ8E9FJ9X3R2RZ6Q4Y 'ST3AM1T9YSC46JQ7C3Y8X4ZK2QXF4E3D1A8G0MEBY)
(clarity-value (contract-call? .dbcoin get-balance-of 'ST2J8EVYHP9MB9XMB6FX6AVZ8E9FJ9X3R2RZ6Q4Y))
```

> Replace the sample principals above with the addresses you want to use in your own tests.

---

## Extending the contract

Some ideas for future improvements:

- Implement the full SIP-010 fungible token trait
- Add `mint` / `burn` functions with access control
- Integrate with other contracts (DEXes, DAOs, etc.)
- Add Clarinet tests under `tests/` to automatically validate behavior
