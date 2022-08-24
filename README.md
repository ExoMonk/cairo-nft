# cairo-nft

NFT Research on StarkNet

## Installation & Setup

```
python -m venv cairo-venv
source cairo-venv/bin/activate

sudo apt install -y libgmp3-dev
(or for M1 macbook)
CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib pip install ecdsa fastecdsa sympy
pip install --upgrade pip
pip install cairo-lang
pip install cairo-nile 
pip install openzeppelin-cairo-contracts
pip install immutablex-starknet

nile init
yarn install
```

## Compiling Contracts

- Compiling Account Contract
```
nile compile contracts/AccountContract.cairo --account_contract
```

- Compiling simple contract

```
nile compile contracts/SimpleERC721.cairo
🔨 Compiling contracts/SimpleERC721.cairo ✅ Done
```


## Deploying Contracts

```
python scripts/deploy.py
```


## Research

StarkNet NFT can be used to leverage a lot of Use Cases
Our first use case is to implement a imple Merkle whitelist using Merkle Proof and Merkle Root : 
`ERC721_whitelist.cairo`


Our second use case is to leverage Account Abstraction and link it to an NFT.
Basically the use case here is to bind an abstracted account to each minted token of the collection and airdrop any token to it.
This could for example be used for backing of the NFT : Let's imagine each time we mint a token, whatever token we are also sending to the contract will be stored in this dedicated token and therefore becoming a Liquid NFT.