# Offensive Claude — Cross-Reference for bbb Framework

**Source:** https://github.com/hypnguyen1209/offensive-claude
**Stars:** 227 ⭐
**Author:** hypnguyen1209
**Type:** Skill taxonomy + vulnerability reference files

---

## Skills Overlap with bbb Framework

| bbb Skill | Offensive Claude Equivalent | Notes |
|-----------|---------------------------|-------|
| crypto-defi-auditor.md | web-pentest (05), vulnerability-analysis (02) | bbb is more focused on DeFi/Web3 |
| enterprise-software-auditor.md | web-pentest (05), coding-mastery (14) | Both cover general security auditing |
| recon-basic.md | recon-osint (01) | Identical domain |
| mcp-security-auditor.md | ai-security (10) | bbb is more MCP-specific |
| oauth-security-auditor.md | web-pentest (05) | OAuth fits within web-pentest |
| parser-differential-tester.md | vulnerability-analysis (02) | Differential testing is a sub-technique |
| prompt-injection-hunter.md | ai-security (10) | Identical domain |
| bucket-squatting-detector.md | recon-osint (01) | Sub-technique of recon |
| yandex-recon-specialist.md | recon-osint (01) | Sub-technique of recon |
| ai-self-validator.md | vulnerability-analysis (02) | Self-validation methodology |
| multi-agent-orchestrator.md | (agents/*) | Both use sub-agents for parallel work |
| framework-librarian.md | (none) | bbb unique - resource management |

### Skills NOT in bbb (borrow candidates)
- **exploit-development (03)** — ROP chains, heap exploitation, shellcode — add for crypto-economic exploit PoCs
- **reverse-engineering (04)** — IDA/Ghidra/Frida — useful for analyzing compiled contracts
- **cloud-security (08)** — AWS/Azure/GCP privesc — useful for protocol backend infrastructure
- **tHreat-hunting (11)** — MITRE ATT&CK mapping — add to findings for professional reporting
- **edr-evasion (17)** — hook unhooking, syscalls — low relevance to DeFi but useful for general pentesting

---

## 47 Vulnerability References — Relevant to Web3/DeFi

### Taint Analysis (4 refs)
- Source-sink tracing: Trace user input → sensitive function in smart contracts
- Filter evaluation: Check sanitization points (require checks, access control modifiers)
- Threat model: Map actors and trust boundaries (users, liquidators, admins, oracles)
- False positive reduction: Context-aware analysis (same as claude-code-security-review)

### Memory Safety (7 refs) — Low for Solidity, high for Rust/Solana
- Buffer overflow: Rust unsafe code in Solana programs
- Integer overflow: Solidity 0.8+ checks, but unchecked blocks
- Out-of-bounds read: Assembly (yul) array access
- Null dereference: Solidity doesn't have null, but address(0) checks

### Injection (11 refs) — Adaptable
- SQL: Subgraph/GraphQL query injection
- Command injection: Off-chain scripts using user input
- XSS: NFT metadata rendering, SVG injection
- SSRF: Bridge relayers, RPC endpoint injection
- Deserialization: Off-chain Python/JS services handling user data
- Path traversal: Contract address resolution from user input

### Authentication (8 refs) — HIGH for DeFi
- Bypass: Missing access control on admin functions
- Authorization flaws: Wrong modifier (onlyOwner vs onlyRole)
- Session management: JWT tokens in protocol frontend
- Hardcoded credentials: Private keys in deployment scripts
- Default credentials: Test accounts in production
- Permissions: Role hierarchy issues

### Cryptography (4 refs) — MEDIUM for DeFi
- Weak algorithms: Precompile usage, ECDSA vs EdDSA
- Key management: Multisig key storage, relayer keys
- Side-channel: Gas consumption reveals state
- Certificate validation: HTTPS endpoints for oracles

### Concurrency (3 refs) — HIGH for DeFi
- Race conditions: Liquidation race, claim race
- TOCTOU: Oracle update window, TWAP manipulation
- Established patterns: Checks-effects-interactions

### Web/API (5 refs) — MEDIUM for DeFi
- CORS: Bridge API, subgraph API
- CSRF: Cross-contract call origin verification
- Open redirect: Phishing via token approval URLs
- API security: GraphQL introspection, rate limiting
- Resource exhaustion: Gas griefing

### Supply Chain (3 refs) — HIGH for DeFi
- Dependency confusion: npm/pip packages used by protocol tooling
- Code integrity: Verification of contract bytecode
- ML model files: AI oracle models

---

## Agent Architecture (for bbb multi-agent orchestration)

| Agent | Role | When to Use |
|-------|------|-------------|
| redteam-planner | Design attack paths, infrastructure | Before starting audit — plan approach |
| exploit-researcher | CVE research, patch diffing | When reading past audit reports |
| security-reviewer | Deep code audit with exploitability validation | Main audit phase |
| reverse-engineer | Binary/firmware analysis | EVM bytecode verification |
| ai-researcher | ML architecture, optimization | AI oracle / G.A.M.E. analysis |
| network-analyst | Packet analysis, protocol dissection | Blockchain node / validator interaction |

---

## Integration Notes

1. Install script: `curl -sL https://raw.githubusercontent.com/hypnguyen1209/offensive-claude/main/install.sh | bash`
2. Skills activate automatically from `~/.claude/skills/`
3. CLAUDE.md sets system prompt (offensive persona)
4. Reference files load on-demand when vulnerability patterns are needed
