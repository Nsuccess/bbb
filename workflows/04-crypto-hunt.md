# Crypto/DeFi Security Hunt

**Target Type:** Smart contracts, DeFi protocols, blockchain applications

**Skills Used:**
- crypto-defi-auditor.md
- ai-self-validator.md

**Expected Time:** 4-8 hours per protocol

---

## Phase 1: Protocol Understanding (60-90 min)

### Step 1.1: Architecture Analysis
**Understand the system:**
- Protocol type (DEX, lending, staking, etc.)
- Token standards (spl-token, ERC-20, etc.)
- Router functionality
- Proxy account patterns
- Oracle integrations

**Document:**
- [ ] Protocol architecture
- [ ] Token flow
- [ ] Key contracts/programs
- [ ] External dependencies
- [ ] Oracle sources

### Step 1.2: Code Review
**Solana:**
```bash
# Clone repository
git clone https://github.com/protocol/contracts

# Review Rust code
cd programs/
ls -la

# Key files to review:
# - lib.rs (main program logic)
# - state.rs (account structures)
# - instructions/ (all instructions)
```

**Ethereum:**
```bash
# Clone repository
git clone https://github.com/protocol/contracts

# Review Solidity code
cd contracts/
ls -la

# Key files to review:
# - Router.sol
# - Pool.sol
# - Oracle.sol
```

### Step 1.3: Identify Key Concepts
**Solana-specific:**
- PDAs (Program Derived Addresses)
- Token accounts
- WSOL (Wrapped SOL)
- Proxy accounts
- Account ordering

**Ethereum-specific:**
- Proxy patterns
- Upgradeable contracts
- Access control
- Reentrancy guards

---

## Phase 2: Accounting Analysis (90-120 min)

**Activate:** `crypto-defi-auditor.md`

### Step 2.1: Balance Mismatch Testing
**Look for:**
- Proxy accounts spending more than intended
- Rounding errors accumulating
- Logic errors in fund transfers
- Missing accounting checks

**Example Test (Solana Router):**
```rust
// Vulnerable pattern:
pub fn execute_route(ctx: Context, amount: u64) {
    transfer_from_user(amount);
    execute_swaps();  // May spend more than amount!
    transfer_to_user();
}

// Test:
// 1. User provides 10 USDC
// 2. Route uses 100 USDC limit order
// 3. Router takes 100 USDC (costs more than user provided)
// 4. Difference taken from proxy account
// Result: User swaps 10 USDC → 100 USDT (router pays 90 USDC)
```

**PoC:**
```bash
# Create test transaction
# Input: 10 USDC
# Route: Uses 100 USDC limit order as intermediary
# Expected: Transaction fails (insufficient funds)
# Vulnerable: Transaction succeeds (proxy pays difference)
```

### Step 2.2: Decimal Precision Testing
**Attack vector:**
- Transfer token with MORE decimals
- Spend inflated amount of token with LESS decimals

**Example (Solana):**
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
```

**PoC:**
```bash
# Test decimal precision attack
# 1. Identify tokens with different decimals
# 2. Create transaction with manipulated account order
# 3. Execute and observe if proxy loses more than expected
```

### Step 2.3: Accounting Check Verification
**Secure pattern:**
```rust
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
```

**Test:**
- Does the contract have accounting checks?
- Can you bypass them?
- What happens if proxy spends more than expected?

---

## Phase 3: Oracle Security (60-90 min)

### Step 3.1: Oracle Hijacking
**Look for:** Case-sensitivity bugs, duplicate markets

**Example (dYdX - Entry #27):**
```go
// Vulnerable: Raw string comparison
for _, market := range k.GetAllMarketParams(ctx) {
    if market.Pair == marketParam.Pair {  // "EIGEN-USD" != "eigen-usd"
        return error
    }
}

// Attack:
// 1. Legitimate market: EIGEN-USD (marketId=33)
// 2. Attacker registers: eigen-usd (marketId=36)
// 3. Both canonicalize to: EIGEN/USD
// 4. Duplicate check uses raw string: passes
// 5. Canonical store overwrites: currencyPairIDStore["EIGEN/USD"] = 36
// 6. All EIGEN/USD oracle updates route to attacker's market
// 7. Original market frozen at stale price
```

**PoC:**
```bash
# Test case-sensitivity in market registration
# 1. Register market with different case
# 2. Check if duplicate detection works
# 3. Verify oracle routing
```

### Step 3.2: Oracle Manipulation
**Test for:**
- Price feed manipulation
- Flash loan attacks
- Sandwich attacks
- Front-running oracle updates

**PoC:**
```bash
# Flash loan attack
# 1. Borrow large amount
# 2. Manipulate price oracle
# 3. Execute profitable trade
# 4. Repay loan
# 5. Keep profit
```

---

## Phase 4: Access Control (30-45 min)

### Step 4.1: Proxy Account Security
**Lessons for router operators:**
1. Don't use proxy accounts as fee receivers
2. Monitor rounding/logic errors
3. Proper accounting (revert if proxy spends more)
4. Have retrieval mechanism for accumulated funds

**Test:**
- Can you drain proxy accounts?
- Can you manipulate account ordering?
- Are there missing permission checks?

### Step 4.2: Permission Checks
**Look for:**
- Missing owner checks
- Weak signer validation
- Account ordering manipulation
- Cross-program invocation (CPI) issues

**Test:**
```rust
// Vulnerable: No owner check
pub fn admin_function(ctx: Context) {
    // No check if caller is admin!
    execute_privileged_action();
}

// Secure: Owner check
pub fn admin_function(ctx: Context) {
    require!(
        ctx.accounts.caller.key() == ADMIN_KEY,
        "Unauthorized"
    );
    execute_privileged_action();
}
```

---

## Phase 5: Solana-Specific Testing (45-60 min)

### Step 5.1: Account Ordering
**Attack vector:** Manipulate account order in transaction

**Example:**
```
Normal: Transfer A → Swap A→B → Transfer B
Attack: Transfer A → Swap B→A (wrong order) → Transfer inflated B
```

**Test:**
- Can you control account order?
- Does the program validate account order?
- What happens with wrong order?

### Step 5.2: PDA Security
**Check:**
- PDA derivation correctness
- Seed validation
- Bump seed handling

**Test:**
```rust
// Vulnerable: No seed validation
let (pda, _bump) = Pubkey::find_program_address(&[b"vault"], program_id);

// Secure: Validate seeds
let (pda, bump) = Pubkey::find_program_address(&[b"vault", user.key().as_ref()], program_id);
require!(pda == ctx.accounts.vault.key(), "Invalid PDA");
```

---

## Phase 6: String Canonicalization (30 min)

### Step 6.1: Case Sensitivity
**Look for:** String comparisons without normalization

**Example (dYdX):**
```go
// VULNERABLE: Raw string comparison
if market.Pair == marketParam.Pair {
    return error
}

// SECURE: Case-insensitive comparison
if strings.EqualFold(market.Pair, marketParam.Pair) {
    return error
}
```

**Test:**
- Register markets/tokens with different cases
- Check if duplicate detection works
- Verify canonicalization is consistent

---

## Phase 7: Validation (30-45 min)

**Activate:** `ai-self-validator.md`

### Step 7.1: Challenge Each Finding
**For each potential vulnerability:**

1. **Verify Exploitability**
   - Can you actually drain funds?
   - Can you manipulate the oracle?
   - Is the accounting error exploitable?

2. **Test Protections**
   - Are there access controls?
   - Are there accounting checks?
   - Are there oracle validations?

3. **Prove Impact**
   - How much can you steal?
   - What's the attack cost?
   - What's the business impact?

### Step 7.2: Create PoC
**Example:**
```bash
#!/bin/bash
# Solana Router Decimal Precision Attack PoC

# Step 1: Setup
solana-keygen new -o attacker.json
solana airdrop 10 attacker.json

# Step 2: Create malicious transaction
# (Manipulate account order to exploit decimal precision)

# Step 3: Execute
solana program invoke \
  --program-id ROUTER_PROGRAM_ID \
  --accounts "..." \
  --data "..."

# Expected: Attacker profits from decimal precision bug
```

---

## Success Criteria

### Critical Findings
- ✅ Fund drain vulnerabilities
- ✅ Oracle hijacking
- ✅ Accounting errors leading to theft
- ✅ Decimal precision attacks
- ✅ Access control bypass

### High Findings
- ✅ Oracle manipulation
- ✅ Reentrancy vulnerabilities
- ✅ Logic flaws
- ✅ Missing validation checks

### Medium Findings
- ✅ Information disclosure
- ✅ Weak access controls
- ✅ Rounding errors

---

## Real Examples (From 72 Resources)

### Solana Router (Entry #16)
**Vulnerabilities:** 2 critical bugs
**Impact:** Could steal ALL funds from router-owned token accounts

**Bug 1: Limit Order Exploit**
- User provides 10 USDC
- Route uses 100 USDC limit order
- Router pays 90 USDC difference from proxy

**Bug 2: Decimal Precision**
- WSOL (9 decimals) vs USDC (6 decimals)
- Account order manipulation
- Attacker profits from precision mismatch

### dYdX v4 (Entry #27)
**Vulnerability:** Oracle hijacking via case-sensitivity
**Impact:** $10,000 to manipulate $1.2M+ open interest

**Attack:**
- Register case-variant ticker (eigen-usd vs EIGEN-USD)
- Redirect oracle to attacker market
- Freeze victim market at stale price

---

## Tools Required

### Solana
- Solana CLI
- Anchor framework
- Rust toolchain
- Solscan (explorer)

### Ethereum
- Hardhat
- Foundry
- Slither (static analysis)
- Mythril (symbolic execution)

### Analysis
- CodeQL
- Custom scripts
- Fuzzing tools

---

## Time Allocation

| Phase | Time | Priority |
|-------|------|----------|
| Protocol Understanding | 60-90 min | CRITICAL |
| Accounting Analysis | 90-120 min | CRITICAL |
| Oracle Security | 60-90 min | HIGH |
| Access Control | 30-45 min | HIGH |
| Solana-Specific | 45-60 min | HIGH (if Solana) |
| String Canonicalization | 30 min | MEDIUM |
| Validation | 30-45 min | CRITICAL |

**Total:** 4-8 hours per protocol

---

## Next Steps After This Workflow

1. **If web interface found:** Try `01-web-app-hunt.md`
2. **If API found:** Try `02-api-security-hunt.md`
3. **If stuck:** Review similar protocols, check for known patterns

---

## References
- Entry #16: Solana Router Critical Vulnerabilities
- Entry #27: dYdX v4 Oracle Hijacking
- Solana Security Best Practices
- DeFi Security Resources
