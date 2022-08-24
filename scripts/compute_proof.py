from merkle_utils import generate_merkle_proof, generate_merkle_root, get_leaves

wallet_addresses = [0x07445bd422E6B9c9cDF04E73A4cF36Ea7c011a737795D13c9342593e789a6a33]

MERKLE_INFO = get_leaves(
    wallet_addresses,
    [1]
)

leaves = list(map(lambda x: x[0], MERKLE_INFO))
root = generate_merkle_root(leaves)


def get_proof_from_whitelist(wallet_address):
    leave_number = wallet_addresses.index(wallet_address)
    proof = generate_merkle_proof(leaves, leave_number)
    return proof
    
def get_root_from_leaves():
    root = generate_merkle_root(leaves)
    return root

def main():
    proof = generate_merkle_proof(leaves, 2)
    print(f'Merkle Root : {root}')
    print(f'Proof {proof}')


if __name__ == '__main__':
    proof = get_proof_from_whitelist(int("0x07445bd422E6B9c9cDF04E73A4cF36Ea7c011a737795D13c9342593e789a6a33", 16), 1)
    print(proof)
