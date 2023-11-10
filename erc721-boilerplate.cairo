%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_contract_address,
    get_block_timestamp,
)
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import (
    split_felt,
    assert_lt_felt,
)
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.access.ownable.library import Ownable
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable

@constructor 
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr} (
    name: felt, symbol: felt, owner: felt
) {
    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);
    ERC721Enumerable.initializer();
    return ();
}

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
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    let (owner: felt) = Ownable.owner();
    return (owner,);
}

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

@view
func returnAllTokensOfUser{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_address : felt
) -> (tokens_len : felt, tokens : felt*) {
    alloc_locals;
    let (user_balance : Uint256) = balanceOf(user_address);
    let balance_as_felt : felt = uint256_to_felt(user_balance);
    let (tokens_len : felt, tokens : felt*) = recursive_tokens(user_address, 0, balance_as_felt);
    return(tokens_len, tokens - tokens_len);
}


func recursive_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    user_address : felt, index : felt, loop_size : felt
) -> (tokens_len : felt, tokens : felt*){
    alloc_locals;
   
    if(loop_size == index){
        let (found_tokens: felt*) = alloc();
        return (0, found_tokens,);
    }
    
    let uint_index : Uint256 = felt_to_uint256(index);
    let (userToken : Uint256) = tokenOfOwnerByIndex(user_address, uint_index);
    let felt_token_id : felt = uint256_to_felt(userToken); 

    let (tokens_len, token_location: felt*) = recursive_tokens(user_address, index + 1, loop_size);
    assert [token_location] = felt_token_id;
    return (tokens_len + 1, token_location + 1,);
}


@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(to :felt) {
    let (supply: Uint256) = ERC721Enumerable.total_supply();
    ERC721Enumerable._mint(to, supply);
    return();
}


@external
func burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (msg_sender) = get_caller_address();
    let (supply: Uint256) = ERC721Enumerable.total_supply();
    let (tokens_len, tokens) = returnAllTokensOfUser(msg_sender);
    recursive_burn(tokens_len, 0 , tokens);

    return();
}


func recursive_burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    size : felt, index : felt, token_ids : felt*
) {
    if(size == index){
        return();
    }

    let tokenId : Uint256 = felt_to_uint256(token_ids[index]);
    ERC721.assert_only_token_owner(tokenId);
    ERC721Enumerable._burn(tokenId);
    return recursive_burn(size, index + 1, token_ids);
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


func felt_to_uint256{range_check_ptr}(x) -> (uint_x: Uint256) {
    let (high, low) = split_felt(x);
    return (Uint256(low=low, high=high),);
}

func uint256_to_felt{range_check_ptr}(value: Uint256) -> (value: felt) {
    assert_lt_felt(value.high, 2 ** 123);
    return (value.high * (2 ** 128) + value.low,);
}
