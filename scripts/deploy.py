import asyncio

from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract
from starknet_py.net.networks import TESTNET
from utils import long_str_to_array, str_to_felt, decimal_to_hex
from compute_proof import get_root_from_leaves, get_leaves

CONTRACT_FILE = ['contracts/ERC721_whitelisted.cairo']

OWNER = 0x07445bd422E6B9c9cDF04E73A4cF36Ea7c011a737795D13c9342593e789a6a33

CONTRACT_URI = long_str_to_array("ipfs://XXX/")
TOKEN_URI = long_str_to_array("ipfs://XXX/")

MAX_SUPPLY = 500

COLLECTION_NAME = str_to_felt('Testnet Collection Symbol')
COLLECTION_SYMBOL = str_to_felt('NFTC')

async def deploy():
    client = GatewayClient(TESTNET)
    root = get_root_from_leaves()
    print("⏳ Deploying ERC721_whitelist Contract...")
    erc721_whitelist_contract = await Contract.deploy(
        client=client,
        compilation_source=CONTRACT_FILE,
        constructor_args=[COLLECTION_NAME, COLLECTION_SYMBOL, OWNER, CONTRACT_URI, TOKEN_URI, MAX_SUPPLY, root]
    )
    print(f'✨ Contract deployed at {decimal_to_hex(erc721_whitelist_contract.deployed_contract.address)}')
    await erc721_whitelist_contract.wait_for_acceptance()
    return (erc721_whitelist_contract)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(deploy())
