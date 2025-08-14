// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { votingSystem } from "../src/codegen/systems/VotingSystemLib.sol";

import { Script } from "./Script.sol";

contract SetModerator is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    startBroadcast();

    // votingSystem.setModerator({ user: address(0x8a99613c003468079f948fd257c53BC30c788bAE), isModerator: false });

    vm.stopBroadcast();
  }
}
