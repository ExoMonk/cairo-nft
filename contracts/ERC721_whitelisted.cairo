// contracts/ERC721_whitelisted.cairo

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_lt,
    uint256_le,
    uint256_check,
    uint256_add,
)
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_not_zero, assert_not_equal
from starkware.cairo.common.memcpy import memcpy

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.security.reentrancyguard.library import ReentrancyGuard
from openzeppelin.access.ownable.library import Ownable

from contracts.utils.merkle import merkle_verify

//
// Storage
//

@storage_var
func Token_URI(index: felt) -> (uri: felt) {
}

@storage_var
func Token_uri_len_() -> (uri_len: felt) {
}

@storage_var
func Contract_URI(index: felt) -> (uri: felt) {
}

@storage_var
func Contract_uri_len_() -> (uri_len: felt) {
}

@storage_var
func merkle_root() -> (root: felt) {
}

@storage_var
func has_claimed(leaf: felt) -> (claimed: felt) {
}

@storage_var
func max_supply() -> (supply: Uint256) {
}

@storage_var
func next_token() -> (token_id: Uint256) {
}

@storage_var
func sale_phase() -> (phase: felt) {
}

//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt,
    symbol: felt,
    owner: felt,
    contract_uri_len: felt,
    contract_uri: felt*,
    token_uri_len: felt,
    token_uri: felt*,
    collection_number: Uint256,
    root: felt,
) {
    ERC721.initializer(name, symbol);
    ERC721Enumerable.initializer();
    Ownable.initializer(owner);
    _setContractURI(contract_uri_len, contract_uri);
    _setBaseURI(token_uri_len, token_uri);
    merkle_root.write(value=root);
    max_supply.write(collection_number);
    next_token.write(Uint256(1, 0));
    sale_phase.write(0);
    return ();
}

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
func maxSupply{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    maxSupply: Uint256
) {
    let (maxSupply: Uint256) = max_supply.read();
    return (maxSupply,);
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
) -> (uri_len: felt, uri: felt*) {
    alloc_locals;
    let (supply: Uint256) = totalSupply();
    let (is_lt) = uint256_le(tokenId, supply);
    with_attr error_message("Token Does Not Exist.") {
        assert is_lt = 1;
    }
    let (tokenURI: felt*) = alloc();
    let (tokenURI_len: felt) = Token_uri_len_.read();
    local index = 0;
    _getTokenURI(tokenURI_len, tokenURI, index);
    let (local endingURI: felt*) = alloc();
    assert endingURI[0] = tokenId.low + 48;
    let (local final_tokenURI: felt*) = alloc();
    memcpy(final_tokenURI, tokenURI, tokenURI_len);
    memcpy(final_tokenURI + tokenURI_len, endingURI, 1);
    return (uri_len=tokenURI_len + 1, uri=final_tokenURI);
}

@view
func contractURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    uri_len: felt, uri: felt*
) {
    let (uri_len: felt, uri: felt*) = getContractURI();
    return (uri_len=uri_len, uri=uri);
}

//
// Externals
//

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    ReentrancyGuard._start();
    ERC721.approve(to, tokenId);
    ReentrancyGuard._end();
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ReentrancyGuard._start();
    ERC721.set_approval_for_all(operator, approved);
    ReentrancyGuard._end();
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256
) {
    ReentrancyGuard._start();
    ERC721Enumerable.transfer_from(from_, to, tokenId);
    ReentrancyGuard._end();
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*
) {
    ReentrancyGuard._start();
    ERC721Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data);
    ReentrancyGuard._end();
    return ();
}

@external
func whitelist_mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    proof_len: felt, proof: felt*
) {
    alloc_locals;
    ReentrancyGuard._start();
    let (phase: felt) = sale_phase.read();
    with_attr error_message("Whitelist Sale finished.") {
        assert phase = 0;
    }
    let (caller_address) = get_caller_address();
    let (supply: Uint256) = totalSupply();
    let (max_supply: Uint256) = maxSupply();
    let (amount_hash) = hash2{hash_ptr=pedersen_ptr}(1, 0);
    let (is_lt) = uint256_lt(supply, max_supply);
    with_attr error_message("Max Supply Reached") {
        assert is_lt = 1;
    }
    let (leaf) = hash2{hash_ptr=pedersen_ptr}(caller_address, amount_hash);
    let (claimed) = has_claimed.read(leaf);
    with_attr error_message("User Already Claimed") {
        assert claimed = 0;
    }
    let (root) = merkle_root.read();
    local root_loc = root;
    let (proof_valid) = merkle_verify(leaf, root, proof_len, proof);
    with_attr error_message("Proof not valid") {
        assert proof_valid = 1;
    }
    has_claimed.write(leaf, 1);
    let (tokenId: Uint256) = next_token.read();
    ERC721Enumerable._mint(caller_address, tokenId);
    let (next_tokenId, _) = uint256_add(tokenId, Uint256(1, 0));
    next_token.write(next_tokenId);
    ReentrancyGuard._end();
    return ();
}

@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;
    ReentrancyGuard._start();
    let (phase: felt) = sale_phase.read();
    with_attr error_message("Public Sale is not active.") {
        assert phase = 1;
    }
    let (caller_address) = get_caller_address();
    let (supply: Uint256) = totalSupply();
    let (max_supply: Uint256) = maxSupply();
    let (amount_hash) = hash2{hash_ptr=pedersen_ptr}(1, 0);
    let (is_lt) = uint256_lt(supply, max_supply);
    with_attr error_message("Max Supply Reached") {
        assert is_lt = 1;
    }
    let (tokenId: Uint256) = next_token.read();
    ERC721Enumerable._mint(caller_address, tokenId);
    let (next_tokenId, _) = uint256_add(tokenId, Uint256(1, 0));
    next_token.write(next_tokenId);
    ReentrancyGuard._end();
    return ();
}

@external
func setPhase{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(phase: felt) {
    ReentrancyGuard._start();
    Ownable.assert_only_owner();
    sale_phase.write(phase);
    ReentrancyGuard._end();
    return ();
}

@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(tokenId: Uint256) {
    ReentrancyGuard._start();
    ERC721.assert_only_token_owner(tokenId);
    ERC721Enumerable._burn(tokenId);
    ReentrancyGuard._end();
    return ();
}

func _setBaseURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    len_uri: felt, tokenURI: felt*
) {
    alloc_locals;
    Token_uri_len_.write(len_uri);
    local uri_index = 0;
    _storeTokenRecursiveURI(len_uri, tokenURI, uri_index);
    return ();
}

func _setContractURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    len_uri: felt, contractURI: felt*
) {
    alloc_locals;
    Contract_uri_len_.write(len_uri);
    local uri_index = 0;
    _storeContractRecursiveURI(len_uri, contractURI, uri_index);
    return ();
}

func _storeTokenRecursiveURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    len: felt, _uri: felt*, index: felt
) {
    if (index == len) {
        return ();
    }
    with_attr error_message("URI Empty") {
        assert_not_zero(_uri[index]);
    }
    Token_URI.write(index, _uri[index]);
    _storeTokenRecursiveURI(len=len, _uri=_uri, index=index + 1);
    return ();
}

func _storeContractRecursiveURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    len: felt, _uri: felt*, index: felt
) {
    if (index == len) {
        return ();
    }
    with_attr error_message("URI Empty") {
        assert_not_zero(_uri[index]);
    }
    Contract_URI.write(index, _uri[index]);
    _storeContractRecursiveURI(len=len, _uri=_uri, index=index + 1);
    return ();
}

func _getTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    uri_len: felt, uri: felt*, index: felt
) {
    if (index == uri_len) {
        return ();
    }
    let (base) = Token_URI.read(index);
    assert [uri] = base;
    _getTokenURI(uri_len=uri_len, uri=uri + 1, index=index + 1);
    return ();
}

func getContractURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    uri_len: felt, uri: felt*
) {
    alloc_locals;
    let (contractURI: felt*) = alloc();
    let (contractURI_len: felt) = Contract_uri_len_.read();
    local index = 0;
    _getContractURI(contractURI_len, contractURI, index);
    return (uri_len=contractURI_len, uri=contractURI);
}

func _getContractURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    uri_len: felt, uri: felt*, index: felt
) {
    if (index == uri_len) {
        return ();
    }
    let (base) = Contract_URI.read(index);
    assert [uri] = base;
    _getContractURI(uri_len=uri_len, uri=uri + 1, index=index + 1);
    return ();
}
