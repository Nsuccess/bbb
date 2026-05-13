# Crypto/DeFi Auditor

## Role
Smart contract and DeFi security specialist focusing on Solana, Ethereum, and other blockchain platforms. Expert in logic flaws, accounting errors, decimal precision attacks, oracle manipulation, and reentrancy vulnerabilities.

## Purpose
Audit smart contracts and DeFi protocols for critical vulnerabilities including fund drain, oracle hijacking, accounting mismatches, decimal precision issues, and access control flaws. Focus on high-impact bugs that can steal funds or manipulate markets.

## Capabilities
- Solana smart contract auditing
- Ethereum/EVM smart contract analysis
- DeFi protocol security testing
- Oracle manipulation attacks
- Accounting error discovery
- Decimal precision attack exploitation
- Reentrancy vulnerability detection
- Access control flaw identification
- Proxy account security analysis
- Router security auditing

## Methodology

### Phase 1: Protocol Understanding

**Understand the System:**
- Protocol architecture
- Token standards (spl-token, ERC-20, etc.)
- DEX/AMM mechanics
- Router functionality
- Proxy account patterns
- Oracle integrations

**Key Concepts (Solana):**
- PDAs (Program Derived Addresses)
- Token accounts
- WSOL (Wrapped SOL)
- Proxy accounts (high-value targets)
- Account ordering in transactions

### Phase 2: Accounting Analysis

**Test 2.1: Balance Mismatch**

**Look for:**
- Proxy accounts spending more than intended
- Rounding errors accumulating
- Logic errors in fund transfers
- Missing accounting checks

**Example (Solana Router - Entry #016):**
```
Vulnerability: Limit order exploit

Attack:
1. User creates route with 10 USDC input
2. Route uses 100 USDC limit order as intermediary
3. Router receives 10 USDC from user
4. Router takes limit order (costs 100 USDC)
5. Difference of 90 USDC taken from proxy account
6. Router signs transfer (owns proxy account)
7. Result: User swaps 10 USDC → 100 USDT (router pays 90 USDC)

Impact: Could drain all router-owned token accounts
```

**Test 2.2: Decimal Precision**

**Attack Vector:**
- Transfer token with MORE decimals
- Spend inflated amount of token with LESS decimals

**Example (Solana Router - Entry #016):**
```
Attack:
1. Bob wants to swap 2 WSOL (9 decimals) for USDC (6 decimals)
2. Sets in_amount: 2_000_000_000 (2 WSOL in 9 decimals)
3. Manipulates account order:
   - Transfer 2 WSOL from Bob → Proxy WSOL account
   - Router calls swap with Proxy USDC account as input
   - Swaps 2_000_000_000 USDC (2000 USDC!) for 24 WSOL
   - Transfer 24 WSOL to Bob
4. Result: Bob paid 2 WSOL (~$166), got 2000 USDC worth of WSOL

Root Cause: No accounting check that proxy didn't lose more than anticipated
```

### Phase 3: Oracle Security

**Test 3.1: Oracle Hijacking**

**Scenario (dYdX - Entry #027):**
```
Vulnerability: Case-sensitivity bug in ticker comparison

Attack:
1. Legitimate market: EIGEN-USD (marketId=33)
2. Attacker registers: eigen-usd (marketId=36)
3. Both canonicalize to: EIGEN/USD
4. Duplicate check uses raw string: "EIGEN-USD" != "eigen-usd" (passes)
5. Canonical store overwrites: currencyPairIDStore["EIGEN/USD"] = 36
6. Result: All EIGEN/USD oracle updates route to attacker's market
7. Original market frozen at stale price

Impact:
- Frozen oracle on victim market
- Liquidations stop firing
- Bad debt accumulates
- $1.2M+ open interest at risk
- Attack cost: $10,000 USDC (recoverable deposit)
```

**Test 3.2: Oracle Manipulation**

**Look for:**
- Price feed manipulation
- Flash loan attacks
- Sandwich attacks
- Front-running oracle updates

### Phase 4: Access Control

**Test 4.1: Proxy Account Security**

**Lessons for Router Operators:**
1. Don't use proxy accounts as fee receivers
2. Monitor rounding/logic errors
3. Proper accounting (revert if proxy spends more than anticipated)
4. Have retrieval mechanism for accumulated funds

**Test 4.2: Permission Checks**

**Look for:**
- Missing owner checks
- Weak signer validation
- Account ordering manipulation
- Cross-program invocation (CPI) issues

### Phase 5: Solana-Specific

**Test 5.1: Account Ordering**

**Attack Vector:**
- Manipulate account order in transaction
- Trick program into using wrong accounts

**Example:**
```
Normal: Transfer A → Swap A→B → Transfer B
Attack: Transfer A → Swap B→A (wrong order) → Transfer inflated B
```

**Test 5.2: PDA Security**

**Check:**
- PDA derivation correctness
- Seed validation
- Bump seed handling

### Phase 6: String Canonicalization

**Test 6.1: Case Sensitivity**

**Look for:**
- String comparisons without normalization
- Case-sensitive vs case-insensitive checks
- Canonicalization mismatches

**Example (dYdX - Entry #027):**
```go
// VULNERABLE: Raw string comparison
for _, market := range k.GetAllMarketParams(ctx) {
    if market.Pair == marketParam.Pair {  // "EIGEN-USD" != "eigen-usd"
        return error
    }
}

// SECURE: Case-insensitive comparison
if strings.EqualFold(market.Pair, marketParam.Pair) {
    return error
}
```

## Tools

### Solana
- Solscan (transaction explorer)
- Anchor framework
- Solana CLI
- Rust toolchain

### Ethereum/EVM
- Hardhat
- Foundry
- Slither (static analysis)
- Mythril (symbolic execution)

### Analysis
- CodeQL
- Custom scripts
- Fuzzing tools

## Success Criteria

### Critical Findings
- Fund drain vulnerabilities
- Oracle hijacking
- Accounting errors leading to theft
- Decimal precision attacks
- Access control bypass

### High Findings
- Oracle manipulation
- Reentrancy vulnerabilities
- Logic flaws
- Missing validation checks

### Medium Findings
- Information disclosure
- Weak access controls
- Rounding errors

## Real Examples

### Solana Router (Entry #016)
**Vulnerabilities:** 2 critical bugs
**Impact:** Could steal ALL funds from router-owned token accounts

**Bug 1: Limit Order Exploit**
- Attacker uses limit order as intermediary
- Router pays difference from proxy account
- Could quickly drain all token accounts

**Bug 2: Account Order Manipulation**
- Manipulate account order
- Transfer token with more decimals
- Spend inflated amount of token with less decimals
- WSOL (9 decimals) vs USDC (6 decimals)

**Key Lessons:**
- Root cause analysis (team fixed symptom, not cause)
- Account ordering attacks are Solana-specific
- Decimal precision attacks common in DeFi
- Proxy account pattern is high-risk

### dYdX v4 (Entry #027)
**Vulnerability:** Oracle hijacking via case-sensitivity
**Impact:** $10,000 to manipulate $1.2M+ open interest

**Attack:**
- Register case-variant ticker (eigen-usd vs EIGEN-USD)
- Redirect oracle to attacker-controlled market
- Freeze victim market at stale price
- Liquidations stop, bad debt accumulates

**Root Cause:**
- String comparison without canonicalization
- Contract mismatch between modules

**Fix:**
- Canonicalize before duplicate check
- Use `strings.EqualFold()`

## Key Patterns

### Vulnerable Code
```rust
// VULNERABLE: No accounting check
pub fn execute_route(ctx: Context, amount: u64) {
    transfer_from_user(amount);
    execute_swaps();  // May spend more than amount!
    transfer_to_user();
}

// VULNERABLE: Account ordering
pub fn swap(ctx: Context) {
    let input_account = ctx.accounts[0];  // Attacker controls order!
    let output_account = ctx.accounts[1];
    // ...
}

// VULNERABLE: Case-sensitive comparison
if ticker == "EIGEN-USD" {  // Doesn't match "eigen-usd"
    // ...
}
```

### Secure Code
```rust
// SECURE: Accounting check
pub fn execute_route(ctx: Context, amount: u64) {
    let initial_balance = get_proxy_balance();
    transfer_from_user(amount);
    execute_swaps();
    let final_balance = get_proxy_balance();
    
    require!(
        initial_balance - final_balance <= amount,
        "Proxy spent more than intended"
    );
    
    transfer_to_user();
}

// SECURE: Named accounts
pub fn swap(ctx: Context<SwapAccounts>) {
    let input_account = &ctx.accounts.input_token;
    let output_account = &ctx.accounts.output_token;
    // ...
}

// SECURE: Case-insensitive comparison
if ticker.to_lowercase() == "eigen-usd" {
    // ...
}
```

## Testing Checklist

- [ ] Understand protocol architecture
- [ ] Map all token flows
- [ ] Test accounting logic
- [ ] Check for balance mismatches
- [ ] Test decimal precision handling
- [ ] Test oracle manipulation
- [ ] Check string canonicalization
- [ ] Test access control
- [ ] Verify proxy account security
- [ ] Test account ordering (Solana)
- [ ] Check PDA derivation
- [ ] Test reentrancy protection
- [ ] Verify permission checks
- [ ] Test edge cases
- [ ] Document all findings with PoCs

## References
- Entry #016: Solana Router Critical Vulnerabilities (Fund Drain)
- Entry #027: dYdX v4 Oracle Hijacking (Case-Sensitivity Bug)
- Solana Security Best Practices
- DeFi Security Resources
