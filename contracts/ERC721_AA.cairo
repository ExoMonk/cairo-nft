# contracts/ERC721_AA.cairo

%lang starknet  

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add

from openzeppelin.account.library import Account, AccountCallArray
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.access.ownable.library import Ownable

from starkware.starknet.common.syscalls import (get_caller_address, get_contract_address, deploy)

from contracts.IDAOToken import IDAOToken

#
# Storage
#

@storage_var
func ERC721_AA_max_assets_by_nft() -> (max_assets_by_nft: Uint256):
end

@storage_var
func ERC721_AA_supply() -> (supply: Uint256):
end

@storage_var
func ERC721_AA_mint_price() -> (mint_price: felt):
end

@storage_var
func ERC721_AA_DAO_token_address_storage() -> (DAO_token_address : felt):
end

@view
func ERC721_AA_DAO_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (DAO_token_address : felt):
    let (address) = ERC721_AA_DAO_token_address_storage.read()
    return (address)
end

@storage_var
func ERC721_AA_Account_Hash_storage() -> (Account_Hash : felt):
end

@view
func ERC721_AA_Account_Hash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    let (address) = ERC721_AA_Account_Hash_storage.read()
    return (address)
end

#Store tokenId
@storage_var
func getNextTokenId() -> (first: Uint256):
end

# Define a storage variable for the salt.
@storage_var
func salt() -> (value : felt):
end

# Define a storage variable for the class hash of ownable_contract.
@storage_var
func ownable_class_hash() -> (value : felt):
end

# An event emitted whenever deploy_individual_contract() is called.
@event
func deployed_individual_contract(contract_address : felt):
end

# A map from token id to account of the NFTvaulT
@storage_var
func NFT_account(token_id : Uint256) -> (address : felt):
end

@view
func NFT_account_view{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token_id : Uint256) -> (address : felt):
    let (address) = NFT_account.read(token_id)
    return (address)
end

#
# Constructor
#

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    name : felt, symbol : felt, supply : Uint256, mint_price : felt, max_assets_by_nft : Uint256, 
    DAO_token_address : felt, Account_hash : felt, owner : felt, public_key: felt
):
    Account.initializer(public_key)
    ERC721.initializer(name, symbol)
    ERC721Enumerable.initializer()
    Ownable.initializer(owner)
    ERC721_AA_max_assets_by_nft.write(max_assets_by_nft)
    ERC721_AA_supply.write(supply)
    ERC721_AA_mint_price.write(mint_price)
    ERC721_AA_DAO_token_address_storage.write(DAO_token_address)
    ERC721_AA_Account_Hash_storage.write(Account_hash)
    getNextTokenId.write(Uint256(1, 0))
    return ()
end


@external
func testFunction{pedersen_ptr : HashBuiltin*, syscall_ptr : felt*, range_check_ptr}():
    return ()
end

###
# ERC721 Functions
###

#
# Getters
#
@view
func totalSupply{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC721Enumerable.total_supply()
    return (totalSupply)
end

@view
func tokenByIndex{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(index: Uint256) -> (tokenId: Uint256):
    let (tokenId: Uint256) = ERC721Enumerable.token_by_index(index)
    return (tokenId)
end

@view
func tokenOfOwnerByIndex{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(owner: felt, index: Uint256) -> (tokenId: Uint256):
    let (tokenId: Uint256) = ERC721Enumerable.token_of_owner_by_index(owner, index)
    return (tokenId)
end

@view
func supportsInterface{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(interfaceId: felt) -> (success: felt):
    let (success) = ERC165.supports_interface(interfaceId)
    return (success)
end

@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC721.name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC721.symbol()
    return (symbol)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC721.balance_of(owner)
    return (balance)
end

@view
func ownerOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (owner: felt):
    let (owner: felt) = ERC721.owner_of(tokenId)
    return (owner)
end

@view
func getApproved{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (approved: felt):
    let (approved: felt) = ERC721.get_approved(tokenId)
    return (approved)
end

@view
func isApprovedForAll{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, operator: felt) -> (isApproved: felt):
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator)
    return (isApproved)
end

@view
func tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(tokenId: Uint256) -> (tokenURI: felt):
    let (tokenURI: felt) = ERC721.token_uri(tokenId)
    return (tokenURI)
end

@view
func owner{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (owner: felt):
    let (owner: felt) = Ownable.owner()
    return (owner)
end

#
# Externals
#

@external
func approve{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(to: felt, tokenId: Uint256):
    ERC721.approve(to, tokenId)
    return ()
end

@external
func setApprovalForAll{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(operator: felt, approved: felt):
    ERC721.set_approval_for_all(operator, approved)
    return ()
end

@external
func transferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256
    ):
    ERC721Enumerable.transfer_from(from_, to, tokenId)
    return ()
end

@external
func safeTransferFrom{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(
        from_: felt,
        to: felt,
        tokenId: Uint256,
        data_len: felt,
        data: felt*
    ):
    ERC721Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data)
    return ()
end

@external
func mint{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(minter_public_key:  felt):
    alloc_locals

    let (tokenId: Uint256) = getNextTokenId.read()
    let (mint_price) = ERC721_AA_mint_price.read()
    let (caller) = get_caller_address()
    let (ERC721_AA_account) = get_contract_address()
    ERC721Enumerable._mint(caller, tokenId)
    #Deploy Account Address
    let (contract_address) = deploy_individual_account(minter_public_key)

    #ajouter une entrée dans le mapping token id / adresse 
    NFT_account.write(tokenId, contract_address)
    let (dao_address) = ERC721_AA_DAO_token_address()
    IDAOToken.transfer(dao_address, contract_address, Uint256(1000, 0))

    let (nextTokenId, carry) = uint256_add(tokenId, Uint256(1, 0))
    getNextTokenId.write(nextTokenId)
    return ()
end



@external
func deploy_individual_account{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(owner_address : felt)-> (contract_address: felt):
    let (current_salt) = salt.read()
    let (class_hash) = ERC721_AA_Account_Hash()
    let (contract_address) = deploy(
        class_hash=class_hash,
        contract_address_salt=current_salt,
        constructor_calldata_size=1,
        constructor_calldata=cast(new (owner_address,), felt*),
        deploy_from_zero=0
    )
    salt.write(value=current_salt + 1)
    deployed_individual_contract.emit(
        contract_address=contract_address
    )
    return (contract_address)
end

@external
func burn{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256):
    ERC721.assert_only_token_owner(tokenId)
    ERC721Enumerable._burn(tokenId)
    return ()
end

@external
func setTokenURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenId: Uint256, tokenURI: felt):
    Ownable.assert_only_owner()
    ERC721._set_token_uri(tokenId, tokenURI)
    return ()
end

@external
func transferOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(newOwner: felt):
    Ownable.transfer_ownership(newOwner)
    return ()
end

@external
func renounceOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }():
    Ownable.renounce_ownership()
    return ()
end


###
# Account Functions
###

#
# Getters
#

@view
func get_public_key{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (res: felt):
    let (res) = Account.get_public_key()
    return (res=res)
end

@view
func get_nonce{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (res: felt):
    let (res) = Account.get_nonce()
    return (res=res)
end


#
# Setters
#

@external
func set_public_key{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(new_public_key: felt):
    Account.set_public_key(new_public_key)
    return ()
end

#
# Business logic
#

@view
func is_valid_signature{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        ecdsa_ptr: SignatureBuiltin*
    }(
        hash: felt,
        signature_len: felt,
        signature: felt*
    ) -> (is_valid: felt):
    let (is_valid) = Account.is_valid_signature(hash, signature_len, signature)
    return (is_valid=is_valid)
end

@external
func __execute__{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        ecdsa_ptr: SignatureBuiltin*,
        bitwise_ptr: BitwiseBuiltin*
    }(
        call_array_len: felt,
        call_array: AccountCallArray*,
        calldata_len: felt,
        calldata: felt*,
        nonce: felt
    ) -> (response_len: felt, response: felt*):
    let (response_len, response) = Account.execute(
        call_array_len,
        call_array,
        calldata_len,
        calldata,
        nonce
    )
    return (response_len=response_len, response=response)
end