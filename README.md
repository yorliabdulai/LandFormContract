# 🧾 LandForm Smart Contracts

Smart contract suite for **LandForm** — powering decentralized land ownership and verification on the blockchain. Built with 🛠 **Hardhat**, and ready for secure, efficient deployment.

![Solidity](https://img.shields.io/badge/solidity-%5E0.8.0-blue.svg?logo=ethereum)
![License](https://img.shields.io/badge/license-ISC-lightgrey.svg)
![Hardhat](https://img.shields.io/badge/Built%20With-Hardhat-yellow.svg)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg)

---

## ⚙️ Overview

This project contains smart contracts essential for managing **digital land records** and facilitating secure **land ownership transactions** via Ethereum-compatible networks.

Features include:

- 📄 Secure land registration
- 👥 Owner verification
- 🔐 Tamper-proof land data on-chain
- 🌐 Interoperability with frontend using **Wagmi** & **RainbowKit**

---

## 📁 Project Structure

```
landform/
├── contracts/        # All Solidity smart contracts
├── scripts/          # Deployment & utility scripts
├── test/             # Test files (if added)
├── .env              # Environment config
├── hardhat.config.js # Hardhat setup
├── package.json      # Project metadata and dependencies
```

---

## 🚀 Getting Started

### ✅ Prerequisites

- Node.js >= 16.x
- Yarn / npm
- Hardhat installed globally or via `npx`

### 🔧 Installation

```bash
git clone https://github.com/yorliabdulai/LandFormContract
cd landform
npm install
```

---

## 🧪 Hardhat Usage

### 🛠 Compile Contracts

```bash
npx hardhat compile
```

### 🚀 Deploy Contracts

```bash
npx hardhat run scripts/deploy.js --network yourNetwork
```

### 🔍 Run Tests

> _Tests not yet added, but you can set up test cases using `chai` and `mocha`._

```bash
npx hardhat test
```

### 📜 Flatten Contract (Optional)

```bash
npx hardhat flatten > flat/LandFormFlat.sol
```

---

## 🔐 Environment Setup

Create a `.env` file in the root directory and add your variables:

```env
PRIVATE_KEY=your_wallet_private_key
INFURA_API_KEY=your_infura_key_or_other_provider
```

---

## 📦 Dependencies

| Package | Purpose |
|--------|---------|
| `hardhat` | Development environment |
| `@nomicfoundation/hardhat-toolbox` | Toolbox for testing, Ethers.js, Chai, etc. |
| `dotenv` | Secure environment variable management |
| `fs-extra` | For extended file operations |
| `wagmi`, `viem`, `rainbowkit` | Web3 integrations for frontend 

---

## 🧩 Integrations

- ⚡ Hardhat for local blockchain simulation
- 🧠 Web3 toolkits to bridge frontend/backend
- 🌐 Ethereum networks via Infura/Alchemy/etc.

---

## 👨‍💻 Author & License

- **Author:** _[LandForm Team]_  
- **License:** ISC, MIT

---

## 🌟 Contributing

We welcome contributions! Here’s how to get involved:

1. 🍴 Fork the repo
2. 🔧 Make changes on a new branch
3. 📬 Submit a PR and describe your changes
4. 💬 Participate in reviews

---

## 🏁 Future Plans

- [ ] Add unit and integration tests  
- [ ] Set up automated deployment scripts  
- [ ] Integrate with full frontend workflow

---

## 📬 Contact

For questions or collaboration opportunities, reach out to us at [iddrisuabdulaiyorli1@gmail.com](mailto:iddrisuabdulaiyorli1@gmail.com).

