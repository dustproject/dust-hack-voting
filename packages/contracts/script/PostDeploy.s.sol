// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { console } from "forge-std/console.sol";

import { Script } from "./Script.sol";

import { bedProgram } from "../src/codegen/systems/BedProgramLib.sol";
import { chestPrizeProgram } from "../src/codegen/systems/ChestPrizeProgramLib.sol";
import { chestProgram } from "../src/codegen/systems/ChestProgramLib.sol";
import { forceFieldProgram } from "../src/codegen/systems/ForceFieldProgramLib.sol";
import { spawnTileProgram } from "../src/codegen/systems/SpawnTileProgramLib.sol";
import { votingSystem } from "../src/codegen/systems/VotingSystemLib.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    StoreSwitch.setStoreAddress(worldAddress);
    address deployer = startBroadcast();

    votingSystem.setModerator({ user: deployer, isModerator: true });
    votingSystem.setModerator({ user: address(0x8a99613c003468079f948fd257c53BC30c788bAE), isModerator: true });
    votingSystem.setConfig({
      votingStartTimestamp: uint32(block.timestamp),
      votingEndTimestamp: 1755280800, // Friday, August 15, 2025 6:00:00 PM (GMT)
      votesPerParticipant: 3
    });

    vm.stopBroadcast();

    if (block.chainid == 31337) {
      console.log("Setting local world address to:", worldAddress);
      _setLocalWorldAddress(worldAddress);
    }
  }

  // Set the world address by directly writing to storage for local setup
  function _setLocalWorldAddress(address worldAddress) internal {
    bytes32 worldSlot = keccak256("mud.store.storage.StoreSwitch");
    bytes32 worldAddressBytes32 = bytes32(uint256(uint160(worldAddress)));
    vm.store(forceFieldProgram.getAddress(), worldSlot, worldAddressBytes32);
    vm.store(spawnTileProgram.getAddress(), worldSlot, worldAddressBytes32);
    vm.store(bedProgram.getAddress(), worldSlot, worldAddressBytes32);
    vm.store(chestProgram.getAddress(), worldSlot, worldAddressBytes32);
    vm.store(chestPrizeProgram.getAddress(), worldSlot, worldAddressBytes32);
  }
}
