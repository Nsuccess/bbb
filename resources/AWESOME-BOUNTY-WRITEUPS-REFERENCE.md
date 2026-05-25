# Awesome Bug Bounty Writeups — Cross-Domain Reference

**Source:** https://github.com/devanshbatham/Awesome-Bugbounty-Writeups
**Stars:** 5,900 ⭐
**Author:** Devansh Batham
**Type:** Curated writeup collection by vulnerability class
**License:** MIT

---

## How to Use This

When auditing a Web3/DeFi protocol, find your vulnerability class below and read 2-3 writeups to understand exploitation patterns. Then adapt the technique to the smart contract environment.

---

## Vulnerability Classes & Web3 Adaptations

### 1. Insecure Direct Object Reference (IDOR)
**Web2 pattern:** User controls an object ID (user_id, account_id, order_id) without ownership verification

**Web3 adaptations:**
- Position NFT ID iteration in VeloPositionManage
- Smart account ID enumeration in ExtraXAccountFactory
- A_Token / Debt_Token ID manipulation
- User account balance enumeration
- Query parameter manipulation in subgraph/GraphQL endpoints

**Example attack:**
```
GET /api/user/1234/transactions → returns user 1234's data
// Change to:
GET /api/user/1235/transactions → returns user 1235's data (no auth check)
```

**Web3 equivalent:**
```
positionManager.positions(1234) → returns position 1234's details
// Try:
positionManager.positions(1235) → also returns data (no ownership check)
```

### 2. Race Conditions
**Web2 pattern:** Two concurrent requests manipulate shared state; TOCTOU (time of check, time of use)

**Web3 adaptations:**
- Liquidation race: front-run health factor check
- Oracle race: TWAP vs spot price window
- Reward claim race: claim before balance updates
- Permit/signature replay across chains
- Withdrawal race: withdraw before balance deduction

**Example attack:**
```
// Coupon redemption race condition
Request 1: POST /redeem/coupon/ABC (with balance X)
Request 2: POST /redeem/coupon/ABC (with balance X, same time)
Both succeed → double redemption
```

**Web3 equivalent:**
```
// Flash loan sandwich on oracle update
TX 1: Manipulate pool reserves
TX 2: Liquidate position at manipulated price
TX 3: Restore pool reserves
All in one block → oracle-based liquidation bypass
```

### 3. Authentication Bypass
**Web2 pattern:** Missing auth check on an endpoint, or bypass via parameter manipulation

**Web3 adaptations:**
- Missing access control on admin functions
- Role grant without timelock
- `onlyOwner` bypass via delegatecall
- Signature verification bypass (missing ecrecover check)
- Permit replay across chains

### 4. Server-Side Request Forgery (SSRF)
**Web2 pattern:** Server fetches a URL controlled by user input

**Web3 adaptations:**
- Bridge relayer fetching from user-controlled URL
- Oracle data feed with user-controllable source
- Node/validator RPC endpoint injection
- Off-chain reward URL fetching
- Metadata URI fetching (tokenURI → attacker server)

### 5. Remote Code Execution (RCE)
**Web2 pattern:** Unsafe deserialization, eval injection, command injection

**Web3 adaptations:**
- delegatecall to untrusted contract address
- CREATE2 deployment with malicious bytecode
- Unsafe `call()` with user-controlled calldata
- Proxy implementation swap
- Solidity assembly (yul) injection

### 6. Cross-Site Request Forgery (CSRF)
**Web2 pattern:** Cross-origin request to state-changing endpoint without verification

**Web3 adaptations:**
- Cross-contract call without origin check
- permit() signature abuse via phishing
- Contract function call via web front-end CSRF
- Meta-transaction relay without tx origin validation

### 7. CORS Misconfiguration
**Web2 pattern:** API returns Access-Control-Allow-Origin: * with credentials

**Web3 adaptations:**
- Bridge/relayer API CORS issues
- Subgraph query API without origin restriction
- Node RPC exposed with permissive CORS
- Admin panel API data leakage via CORS

### 8. SQL Injection
**Web2 pattern:** Unsanitized user input in SQL query

**Web3 adaptations:**
- Subgraph/GraphQL query injection
- On-chain indexer query manipulation
- Database queries from off-chain services
- Event log query injection
- The Graph subgraph mapping injection

### 9. Broken Access Control / Privilege Escalation
**Web2 pattern:** User can access or perform actions at a higher privilege level

**Web3 adaptations (CRITICAL):**
- DEFAULT_ADMIN_ROLE compromise → full protocol drain
- MINTER_ROLE abuse → unlimited token minting
- PoolConfigurator parameter changes without timelock
- Proxy admin change → implementation swap to malicious
- PAUSER_ROLE abuse → freeze all withdrawals

---

## Cross-Domain Attack Chains

These are real attack scenarios that combine Web2 and Web3 techniques:

### Chain 1: Web2 Auth → Web3 Drain
1. Find SSRF in bridge frontend API (Web2)
2. SSRF → internal admin panel (Web2)
3. Steal admin session token (Web2)
4. Use admin token to upgrade bridge contract (Web3)
5. Drain bridge funds (Web3)

### Chain 2: Web3 Frontend → Web2 Admin
1. Find IDOR in subgraph query API (Web3→Web2)
2. Enumerate all user email addresses (Web2)
3. Find password reset endpoint without rate limit (Web2)
4. Reset admin password (Web2)
5. Use admin access to modify protocol contract (Web3)

### Chain 3: Smart Contract → Off-chain Backend
1. Deploy malicious ERC20 that returns manipulated `decimals()` (Web3)
2. Off-chain price feed reads wrong decimals value (Web2)
3. Oracle reports incorrect price (Web2)
4. Trigger false liquidation based on wrong price (Web3)

---

## How to Find Cross-Domain Bugs

1. **For each Web3 function, ask:** "Could a Web2 version of this function have a bug?"
   - Contract function `withdraw(amount, to)` → same as Web2 API `GET /withdraw?amount=X&to=Y`
   - Check for missing ownership verification (= IDOR)

2. **For each off-chain component, ask:** "Does this have web security issues?"
   - Bridge frontend → CSRF, XSS, CORS issues
   - Indexer → SQLi, SSRF
   - Admin panel → Auth bypass, IDOR

3. **For each trusted component, ask:** "What if this is untrusted?"
   - Trusted relayer → SSRF
   - Trusted oracle → XXE, injection
   - Trusted admin → role abuse
   - Trusted contract → delegatecall hijack
