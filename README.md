SimpleSwap AMM Project

Overview

This repository contains the source code and documentation for a basic Automated Market Maker (AMM) system implemented on the Ethereum Sepolia testnet. The project includes two ERC20 tokens (TokenA and TokenB) and a SimpleSwap contract that facilitates token swaps and liquidity provision.





TokenA (TKA): An ERC20 token with minting functionality restricted to the owner.



TokenB (TKB): Another ERC20 token with similar functionality.



SimpleSwap: A liquidity pool and swapping contract using a constant product formula.

This project was developed as part of a practical assignment to demonstrate Solidity programming, smart contract deployment, and verification on Etherscan.

Contracts





TokenA.sol: Implements the ERC20 standard with an initial supply of 1,000,000 TKA tokens.



TokenB.sol: Implements the ERC20 standard with an initial supply of 1,000,000 TKB tokens.



SimpleSwap.sol: Provides functions for adding/removing liquidity and swapping tokens between TokenA and TokenB.

Deployment Details





Network: Ethereum Sepolia Testnet



Compiler Version: Solidity ^0.8.20 (used v0.8.30 for TokenA/TokenB, v0.8.0 for SimpleSwap)



Optimization: Disabled



Deployed Addresses:





TokenA: Insert TokenA Address Link



TokenB: Insert TokenB Address Link



SimpleSwap: Insert SimpleSwap Address Link



Verification: All contracts are verified on Sepolia Etherscan.

Usage





Prerequisites:





Install MetaMask and connect to the Sepolia network.



Obtain Sepolia ETH from a faucet (e.g., https://sepoliafaucet.com/).



Use Remix IDE (https://remix.ethereum.org) for compilation and deployment.



Deployment:





Open each .sol file in Remix.



Compile with the specified compiler version.



Deploy using "Injected Provider - MetaMask" with no constructor arguments for TokenA and TokenB, and the TokenA/TokenB addresses for SimpleSwap.



Confirm transactions in MetaMask.



Interaction:





Add liquidity to SimpleSwap using addLiquidity with TokenA and TokenB amounts.



Swap tokens using swapExactTokensForTokens.



Remove liquidity with removeLiquidity.

Flattened Contracts

Flattened versions of the contracts (including OpenZeppelin imports) are available in the flatten/ directory for Etherscan verification:





TokenA_flat.sol



TokenB_flat.sol



SimpleSwap_flat.sol

Testing

(Include testing details if applicable, e.g., manual tests via Remix or automated tests. If none, remove this section.)

License

This project is licensed under the MIT License - see the LICENSE file for details (add a LICENSE file if not present).

Acknowledgments





Built using OpenZeppelin contracts for security and standards.



Deployed and verified with assistance from Remix and Etherscan.
