> For Mintlify product knowledge (components, configuration, writing standards),
> install the Mintlify skill: `npx skills add https://mintlify.com/docs`

# Documentation project instructions

## About this project

- This is the developer documentation for **Qustody**, the **Quantum Chain Custody API**
- Built on [Mintlify](https://mintlify.com) with MDX pages and YAML frontmatter
- Configuration lives in `docs.json`
- API reference is auto-generated from `api-reference/openapi.json`
- Run `mint dev` to preview locally
- Run `mint broken-links` to check links

## Terminology

- **Qustody** — the product name for the Quantum Chain Custody platform; use "Qustody" in the site header, logo, and first mention per page, then "Custody API" or "the API" for subsequent references
- **Quantum Chain (QC)** — post-quantum Ethereum fork using proprietary quantum-safe signatures
- **Vault account** — logical grouping that holds one or more wallets (not "vault" alone)
- **Wallet** — a single Quantum Chain address within a vault account; holds assets and signs transactions
- **Non-custodial** — the API never holds private keys; signing happens via external callback
- **Signing callback** — HTTP callback sent to the integrator's signer to produce a post-quantum signature
- **Signing payload** — the unsigned transaction digest returned by `GET /transactions/{id}/signing_payload`
- **Transaction lifecycle** — PENDING_SIGNATURE → SIGNED → BROADCASTING → CONFIRMING → COMPLETED (or FAILED/CANCELLED)
- **Policy** — a rule (MAX_AMOUNT, WHITELIST, BLACKLIST, REQUIRE_APPROVAL, TIME_WINDOW, DAILY_LIMIT) enforced before a transaction is broadcast
- **Webhook** — HMAC-SHA256-signed HTTP event notification delivered to integrator endpoints
- **Tenant** — an isolated organizational unit; each tenant has its own vaults, wallets, policies, and credentials
- **Chain ID** — 20803 (Quantum Chain mainnet)
- **Bearer API key** — authentication format: `Authorization: Bearer <key_id>:<secret>`

## Style preferences

- Use active voice and second person ("you")
- Keep sentences concise — one idea per sentence
- Use sentence case for headings
- Bold for UI elements: Click **Settings**
- Code formatting for file names, commands, paths, and code references
- Always use "Quantum Chain" (two words, capitalized) — never "quantum chain" or "QuantumChain"
- Prefer "vault account" over "vault" when referring to the container resource
- Use "post-quantum" or "quantum-safe" when referring to the signature scheme — never name the specific algorithm
- Never use em dashes (—) in prose; use periods, commas, colons, or parentheses instead. Em dashes are allowed only as table-cell placeholders
- For definition lists ("**Term** — description"), use "**Term.** Description" or "**Term:** description"
- Avoid AI-sounding filler: "it's worth noting", "importantly", "notably", "robust", "comprehensive", "seamlessly", "leverage", "cutting-edge", "delve", "myriad"

## Content boundaries

- Do not document internal admin-only features or database schemas
- Do not expose private key management details — the API is non-custodial
- Do not reference deprecated plant store demo content
- Keep API reference pages generated from OpenAPI — do not duplicate endpoint schemas in guides
