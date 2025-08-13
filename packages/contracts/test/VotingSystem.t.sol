// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { HookContext, ITransfer, SlotData } from "@dust/world/src/ProgramHooks.sol";
import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "@dust/world/src/types/ObjectType.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { console } from "forge-std/console.sol";

import { Constants } from "../src/Constants.sol";

import { chestCounterProgram } from "../src/codegen/systems/ChestCounterProgramLib.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract VotingSystemTest is MudTest {
  function setUp() public override {
    super.setUp();

    bytes32 worldSlot = keccak256("mud.store.storage.StoreSwitch");
    bytes32 worldAddressBytes32 = bytes32(uint256(uint160(worldAddress)));
    vm.store(address(program), worldSlot, worldAddressBytes32);
  }
}
