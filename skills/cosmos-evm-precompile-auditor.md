# Cosmos EVM Precompile Auditor Skill

**Source:** https://github.com/NibiruChain/nibiru/commit/c239445ca45c21453a9d88e96b95f9690fae8780
**Bounty:** $15,000
**Vuln Type:** Callback-based Privilege Escalation via Precompile Reentrancy

---

## Vulnerability Pattern: Module-Originated Callback Privilege Escalation

### The Pattern
When a Cosmos module calls a user-deployed EVM contract, the `from` address carries the module's authority. Any callback from that contract back into the system's precompiles inherits the module's privileges.

### Detection Checklist

- [ ] Does any Cosmos module call user-deployed EVM contracts directly?
- [ ] Is the module's address (e.g., `EVM_MODULE_ADDRESS`) used as the caller for these calls?
- [ ] Is it used for BOTH read operations (queries) AND write operations (transfers)?
- [ ] During the call, can the user contract's callback re-enter system precompiles?
- [ ] Are there mutable precompile functions (bankMsgSend, execute, instantiate) accessible via delegatecall?
- [ ] Is there a context guard distinguishing "direct user call" from "nested call during module execution"?
- [ ] If No to any of above → **VULNERABLE**

### Attack Flow
```
1. User calls module function (e.g., ConvertCoinToEvm)
2. Module calls ERC20.transfer() on user's token contract from EVM_MODULE_ADDRESS
3. Malicious ERC20.transfer() makes delegatecall to FunToken precompile:
   delegatecall(FunToken.bankMsgSend(...))
4. Precompile processes request because caller is EVM_MODULE_ADDRESS (trusted)
5. Attacker drains funds / executes privileged operations
```

### Mitigations (3 layers)

**Layer 1 — Context Guard:**
```go
// Set flag during module-originated calls
if fromAcc == evm.EVM_MODULE_ADDRESS {
    ctx = ctx.WithValue("evm_vm_sender_guard", true)
}

// Check in precompile methods
func assertNotVMCaller(ctx) {
    if IsVMSenderCtx(ctx) {
        return error("disabled during EVM callback")
    }
}
```

**Layer 2 — Read/Write Privilege Separation:**
Use a separate low-privilege address for read-only queries:
```go
EVM_READONLY_ADDR // for metadata/balance queries
EVM_MODULE_ADDRESS // ONLY for write operations
```

**Layer 3 — Guard in Every Mutable Precompile Method:**
```go
func (p precompileFunToken) sendToBank(...) {
    if err := assertNotVMCaller(ctx); err != nil { return nil, err }
    if err := assertNotReadonlyTx(readOnly, method); err != nil { return nil, err }
    // ... execute bank send
}
```

### Testing
- Create a `MaliciousCallback.sol` contract that overrides `transfer()` with a delegatecall to precompile
- Test that mutable precompile methods fail during module-originated callbacks
- Verify balance invariance (no state changes when guard blocks)

---

## General Cosmos EVM Security Patterns

### Precompile Security
| Check | Why |
|-------|-----|
| Context-aware guard for module-originated calls | Prevents callback privilege escalation |
| Read/Write address separation | Limits blast radius of read operations |
| ABI-encoded revert errors | Solidity callers must handle failures |
| Gas metering for precompile calls | Prevents gas griefing |
| Reentrancy guards when calling back to EVM | Prevents recursive state changes |

### Module → EVM Interaction
| Check | Why |
|-------|-----|
| Check call-origin vs call-sender | Module address authority can be hijacked |
| Guard scoping (set/restore) | Flag shouldn't leak to unrelated calls |
| All mutable precompile methods checked | Any unchecked method = exploit vector |
| Test with malicious callback contract | Happy path testing is insufficient |

### Upgrade/Governance
| Check | Why |
|-------|-----|
| Precompile address hardcoded or upgradeable? | If upgradeable, governance attack can swap precompile |
| Module parameters changeable via governance? | Parameter manipulation attacks |
| Emergency pause for dangerous operations? | Can stop exploit in progress |

---

## Cross-Reference

- **CWE-841**: Improper Enforcement of Behavioral Workflow
- **CWE-284**: Improper Access Control
- **CWE-665**: Improper Initialization
- **Related:** EchoProtocol $770k (admin compromise via role grant)
- **Related:** Manta Network $2.2M (oracle manipulation via callback)
