# DarkButterfly

DarkButterfly is a starter repository for an ERC-20 token that takes a buy/sell tax and can automatically convert collected taxes to ETH and forward them to a marketing wallet. It also includes a simple, pluggable Node.js marketing poster that can publish content to social platforms (requires provider API keys).

DISCLAIMER
- This repository is a starter template. You must get the token contract audited and comply with laws and platform terms before launching.
- Do NOT use this for spammy or unlawful marketing.
- Taxes are configurable, but the example sets 5% buy / 5% sell. Owner privileges exist; use responsibly.

Contents
- contracts/DarkButterfly.sol — ERC-20 with buy/sell taxes and automatic swap-to-ETH.
- hardhat.config.js & scripts/deploy.js — Hardhat deployment.
- backend/poster — Node service to publish marketing posts to configured providers.
- .env.example — environment variables example.

Quick start (development)
1. Install dependencies
   - Node.js 18+, npm or yarn
   - Hardhat

2. Clone locally and install:
   - npm install
3. Configure .env (see .env.example)
4. Compile and run tests (if added) / Deploy on testnet with Hardhat script.

Marketing bot
- The poster is modular: implement adapters for each platform you intend to use and supply API keys in .env.
- Obey API terms and rate limits. The example uses placeholders; register for official developer APIs.

Taxes
- The default buyFee and sellFee are set to 5 each (interpreted as percent). Values can be changed by owner up to a hard cap.

Security & legal checklist
- Audit the smart contract
- Consider multisig ownership for critical functions
- Publish full tokenomics and disclosures
- Follow tax and securities law guidance in your jurisdiction

What I included for you:
- Solidity contract with automatic tax collection and swap-to-ETH via UniswapV2Router.
- Deployment script (Hardhat).
- Marketing poster skeleton with Twitter/X and Instagram adapter placeholders (you must supply API keys).
- README & .env example.

Next steps I can help with:
- Customize tokenomics or add vesting/liquidity locks
- Harden contract (anti-bot, anti-sniping)
- Implement real provider adapters for Twitter (X) or Instagram using their official APIs
- Prepare a deployment plan and checklist for launch day
