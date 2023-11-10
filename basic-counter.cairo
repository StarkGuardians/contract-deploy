// SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256


@storage_var
func counter() -> (res: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    return ();
}

@view
func getCounter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    return counter.read();
}

@external
func increase{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount : felt
) -> () {
    let cc : felt = counter.read();
    let res : felt = cc + amount;
    counter.write(res);
    return ();
}


@external
func decrease{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    recipient: felt, amount : felt
) -> () {
    let cc : felt = counter.read();
    let res : felt = cc - amount;
    counter.write(res);
    return ();
}
