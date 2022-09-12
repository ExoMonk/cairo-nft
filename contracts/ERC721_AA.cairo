%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add

from openzeppelin.account.library import Account, AccountCallArray
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.access.ownable.library import Ownable

from starkware.starknet.common.syscalls import get_caller_address, get_contract_address, deploy, get_tx_info

from contracts.IDAOToken import IDAOToken

//
// Storage
//

@storage_var
func ERC721_AA_max_assets_by_nft() -> (max_assets_by_nft: Uint256) {
}

@storage_var
func ERC721_AA_supply() -> (supply: Uint256) {
}

@storage_var
func ERC721_AA_mint_price() -> (mint_price: felt) {
}

@storage_var
func ERC721_AA_DAO_token_address_storage() -> (DAO_token_address: felt) {
}

@view
func ERC721_AA_DAO_token_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (DAO_token_address: felt) {
    let (address) = ERC721_AA_DAO_token_address_storage.read();
    return (address,);
}

@storage_var
func ERC721_AA_Account_Hash_storage() -> (Account_Hash: felt) {
}

@view
func ERC721_AA_Account_Hash{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        hash: felt
    ) {
    let (address) = ERC721_AA_Account_Hash_storage.read();
    return (address,);
}

// Store tokenId
@storage_var
func getNextTokenId() -> (first: Uint256) {
}

// Define a storage variable for the salt.
@storage_var
func salt() -> (value: felt) {
}

// Define a storage variable for the class hash of ownable_contract.
@storage_var
func ownable_class_hash() -> (value: felt) {
}

// An event emitted whenever deploy_individual_contract() is called.
@event
func deployed_individual_contract(contract_address: felt) {
}

// A map from token id to account of the NFTvaulT
@storage_var
func NFT_account(token_id: Uint256) -> (address: felt) {
}

@view
func NFT_account_view{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (address: felt) {
    let (address) = NFT_account.read(token_id);
    return (address,);
}

//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt,
    symbol: felt,
    supply: Uint256,
    mint_price: felt,
    max_assets_by_nft: Uint256,
    DAO_token_address: felt,
    Account_hash: felt,
    owner: felt,
    public_key: felt,
) {
    Account.initializer(public_key);
    ERC721.initializer(name, symbol);
    ERC721Enumerable.initializer();
    Ownable.initializer(owner);
    ERC721_AA_max_assets_by_nft.write(max_assets_by_nft);
    ERC721_AA_supply.write(supply);
    ERC721_AA_mint_price.write(mint_price);
    ERC721_AA_DAO_token_address_storage.write(DAO_token_address);
    ERC721_AA_Account_Hash_storage.write(Account_hash);
    getNextTokenId.write(Uint256(1, 0));
    return ();
}

@external
func testFunction{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    return ();
}

//##
// ERC721 Functions
//##

//
// Getters
//
@view
func totalSupply{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    totalSupply: Uint256
) {
    let (totalSupply: Uint256) = ERC721Enumerable.total_supply();
    return (totalSupply,);
}

@view
func tokenByIndex{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    index: Uint256
) -> (tokenId: Uint256) {
    let (tokenId: Uint256) = ERC721Enumerable.token_by_index(index);
    return (tokenId,);
}

@view
func tokenOfOwnerByIndex{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    owner: felt, index: Uint256
) -> (tokenId: Uint256) {
    let (tokenId: Uint256) = ERC721Enumerable.token_of_owner_by_index(owner, index);
    return (tokenId,);
}

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interfaceId: felt
) -> (success: felt) {
    let (success) = ERC165.supports_interface(interfaceId);
    return (success,);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    owner: felt
) {
    let (owner: felt) = ERC721.owner_of(tokenId);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(tokenId);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (isApproved: felt) {
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (isApproved,);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (tokenURI: felt) {
    let (tokenURI: felt) = ERC721.token_uri(tokenId);
    return (tokenURI,);
}

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    let (owner: felt) = Ownable.owner();
    return (owner,);
}

//
// Externals
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    ERC721.approve(to, tokenId);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256
) {
    ERC721Enumerable.transfer_from(from_, to, tokenId);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*
) {
    ERC721Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data);
    return ();
}

@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    minter_public_key: felt
) {
    alloc_locals;

    let (tokenId: Uint256) = getNextTokenId.read();
    let (mint_price) = ERC721_AA_mint_price.read();
    let (caller) = get_caller_address();
    let (ERC721_AA_account) = get_contract_address();
    ERC721Enumerable._mint(caller, tokenId);
    // Deploy Account Address
    let (contract_address) = deploy_individual_account(minter_public_key);

    // ajouter une entrée dans le mapping token id / adresse
    NFT_account.write(tokenId, contract_address);
    let (dao_address) = ERC721_AA_DAO_token_address();
    IDAOToken.transfer(dao_address, contract_address, Uint256(1000, 0));

    let (nextTokenId, carry) = uint256_add(tokenId, Uint256(1, 0));
    getNextTokenId.write(nextTokenId);
    return ();
}

@external
func deploy_individual_account{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner_address: felt
) -> (contract_address: felt) {
    let (current_salt) = salt.read();
    let (class_hash) = ERC721_AA_Account_Hash();
    let (contract_address) = deploy(
        class_hash=class_hash,
        contract_address_salt=current_salt,
        constructor_calldata_size=1,
        constructor_calldata=cast(new (owner_address,), felt*),
        deploy_from_zero=0,
    );
    salt.write(value=current_salt + 1);
    deployed_individual_contract.emit(contract_address=contract_address);
    return (contract_address,);
}

@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(tokenId: Uint256) {
    ERC721.assert_only_token_owner(tokenId);
    ERC721Enumerable._burn(tokenId);
    return ();
}

@external
func setTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256, tokenURI: felt
) {
    Ownable.assert_only_owner();
    ERC721._set_token_uri(tokenId, tokenURI);
    return ();
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    newOwner: felt
) {
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.renounce_ownership();
    return ();
}

//##
// Account Functions
//##

//
// Getters
//

@view
func get_public_key{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let (res) = Account.get_public_key();
    return (res=res);
}

//
// Setters
//

@external
func set_public_key{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_public_key: felt
) {
    Account.set_public_key(new_public_key);
    return ();
}

//
// Business logic
//

@view
func is_valid_signature{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, ecdsa_ptr: SignatureBuiltin*
}(hash: felt, signature_len: felt, signature: felt*) -> (is_valid: felt) {
    let (is_valid) = Account.is_valid_signature(hash, signature_len, signature);
    return (is_valid=is_valid);
}


@external
func __validate__{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, ecdsa_ptr: SignatureBuiltin*, range_check_ptr
}(call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*) {
    let (tx_info) = get_tx_info();
    Account.is_valid_signature(tx_info.transaction_hash, tx_info.signature_len, tx_info.signature);
    return ();
}

@external
func __validate_declare__{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, ecdsa_ptr: SignatureBuiltin*, range_check_ptr
}(class_hash: felt) {
    let (tx_info) = get_tx_info();
    Account.is_valid_signature(tx_info.transaction_hash, tx_info.signature_len, tx_info.signature);
    return ();
}


@external
func __execute__{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    ecdsa_ptr: SignatureBuiltin*,
    bitwise_ptr: BitwiseBuiltin*,
}(
    call_array_len: felt,
    call_array: AccountCallArray*,
    calldata_len: felt,
    calldata: felt*
) -> (response_len: felt, response: felt*) {
    let (response_len, response) = Account.execute(
        call_array_len, call_array, calldata_len, calldata
    );
    return (response_len=response_len, response=response);
}
