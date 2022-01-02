%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import assert_nn_le, unsigned_div_rem, assert_not_zero
from starkware.cairo.common.math_cmp import is_nn_le
from starkware.cairo.common.hash_state import hash_init, hash_update, HashState
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_eq

from contracts.settling_game.utils.interfaces import IModuleController, I03B_Buildings
from contracts.settling_game.utils.general import unpack_data

from contracts.settling_game.utils.game_structs import (
    RealmBuildings, RealmData, RealmBuildingCostIds, RealmBuildingCostValues)
from contracts.token.IERC20 import IERC20
from contracts.token.ERC1155.IERC1155 import IERC1155
from contracts.settling_game.interfaces.realms_IERC721 import realms_IERC721
from contracts.settling_game.interfaces.s_realms_IERC721 import s_realms_IERC721

# #### Module 3A ####
#                   #
# Buildings Logic   #
#                   #
#####################

@storage_var
func controller_address() -> (address : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        address_of_controller : felt):
    # Store the address of the only fixed contract in the system.
    controller_address.write(address_of_controller)
    return ()
end

@external
func build{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*}(
        token_id : Uint256, building_id : felt, token_ids_len : felt, token_ids : felt*,
        token_values_len : felt, token_values : felt*):
    alloc_locals

    let (caller) = get_caller_address()
    let (controller) = controller_address.read()

    # s realms address
    let (s_realms_address) = IModuleController.get_s_realms_address(contract_address=controller)

    # check owner
    let (owner) = realms_IERC721.ownerOf(contract_address=s_realms_address, token_id=token_id)
    assert caller = owner

    # realms address
    let (realms_address) = IModuleController.get_realms_address(contract_address=controller)

    # realms data
    let (realms_data : RealmData) = realms_IERC721.fetch_realm_data(
        contract_address=realms_address, token_id=token_id)

    # building state address
    let (buildings_state_address) = IModuleController.get_module_address(
        contract_address=controller, module_id=6)

    # get current buildings already constructed
    let (current_building) = I03B_Buildings.get_realm_building_by_id(
        buildings_state_address, token_id, building_id)

    # check can build
    if building_id == 1:
        if realms_data.regions == current_building:
            return ()
        end
    end

    # get costs of building
    let (_token_ids_len, ids) = fetch_building_cost_ids(building_id)
    let (_token_values_len, values) = fetch_building_cost_values(building_id)

    check_correct_resources(
        building_id,
        token_ids_len,
        token_ids,
        token_values_len,
        token_values,
        _token_ids_len,
        ids,
        _token_values_len,
        values)

    # check resources values and ids

    # burn resource values

    # increment building

    return ()
end

func check_correct_resources{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*}(
        building_id : felt, token_ids_len : felt, token_ids : felt*, token_values_len : felt,
        token_values : felt*, ids_len : felt, ids : felt*, values_len : felt, values : felt*):
    return check_correct_resources(
        building_id=building_id,
        token_ids_len=token_ids_len - 1,
        token_ids=token_ids + 1,
        token_values_len=token_values_len - 1,
        token_values=token_values + 1,
        ids_len=ids_len - 1,
        ids=ids + 1,
        values_len=values_len - 1,
        values=values + 1)
end

@external
func fetch_building_cost_ids{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*}(building_id : felt) -> (
        realm_building_ids_len : felt, realm_building_ids : felt*):
    alloc_locals

    let (controller) = controller_address.read()

    # state contract
    let (buildings_state_address) = IModuleController.get_module_address(
        contract_address=controller, module_id=6)

    let (local data) = I03B_Buildings.get_building_cost_ids(buildings_state_address, building_id)

    let (local resource_1) = unpack_data(data, 0, 255)
    let (local resource_2) = unpack_data(data, 8, 255)
    let (local resource_3) = unpack_data(data, 16, 255)
    let (local resource_4) = unpack_data(data, 24, 255)
    let (local resource_5) = unpack_data(data, 32, 255)
    let (local resource_6) = unpack_data(data, 40, 255)
    let (local resource_7) = unpack_data(data, 48, 255)
    let (local resource_8) = unpack_data(data, 56, 255)
    let (local resource_9) = unpack_data(data, 64, 255)
    let (local resource_10) = unpack_data(data, 72, 255)

    let (local resource_ids : felt*) = alloc()
    local l

    if resource_1 != 0:
        resource_ids[0] = resource_1
        l = l; ap++
    end

    return (l,  resource_ids)
end

@external
func fetch_building_cost_values{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*}(building_id : felt) -> (
        realm_building_costs_len : felt, realm_building_costs : felt*):
    alloc_locals

    let (controller) = controller_address.read()

    # state contract
    let (buildings_state_address) = IModuleController.get_module_address(
        contract_address=controller, module_id=6)

    let (local data) = I03B_Buildings.get_building_cost_ids(buildings_state_address, building_id)

    let (local resource_1_values) = unpack_data(data, 0, 4095)
    let (local resource_2_values) = unpack_data(data, 12, 4095)
    let (local resource_3_values) = unpack_data(data, 24, 4095)
    let (local resource_4_values) = unpack_data(data, 36, 4095)
    let (local resource_5_values) = unpack_data(data, 48, 4095)
    let (local resource_6_values) = unpack_data(data, 60, 4095)
    let (local resource_7_values) = unpack_data(data, 62, 4095)
    let (local resource_8_values) = unpack_data(data, 74, 4095)
    let (local resource_9_values) = unpack_data(data, 86, 4095)
    let (local resource_10_values) = unpack_data(data, 98, 4095)

    let (local resource_values : felt*) = alloc()
    local l

    if resource_1_values != 0:
        resource_values[0] = resource_1_values
        l = l; ap++
    end

    return (l, resource_values)
end
