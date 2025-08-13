// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { HookContext, ITransfer } from "@dust/world/src/ProgramHooks.sol";
import { System, WorldContextConsumer } from "@latticexyz/world/src/System.sol";

import { BaseProgram } from "./BaseProgram.sol";

contract ChestPrizeProgram is ITransfer, System, BaseProgram {
  function onTransfer(HookContext calldata ctx, TransferData calldata) external view onlyWorld {
    if (!ctx.revertOnFailure) return;

    // TODO: Implement prize distribution logic
  }

  // Required due to inheriting from System and WorldConsumer
  function _msgSender() public view override(WorldContextConsumer, BaseProgram) returns (address) {
    return BaseProgram._msgSender();
  }

  function _msgValue() public view override(WorldContextConsumer, BaseProgram) returns (uint256) {
    return BaseProgram._msgValue();
  }
}
