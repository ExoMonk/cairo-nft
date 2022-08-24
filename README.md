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
