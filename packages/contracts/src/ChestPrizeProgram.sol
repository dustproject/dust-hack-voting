// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { HookContext, ITransfer, SlotData } from "@dust/world/src/ProgramHooks.sol";
import { System, WorldContextConsumer } from "@latticexyz/world/src/System.sol";

import { BaseProgram } from "./BaseProgram.sol";
import { Submissions } from "./codegen/tables/Submissions.sol";
import { Config } from "./codegen/tables/Config.sol";
import { SubmissionCreators } from "./codegen/tables/SubmissionCreators.sol";
import { ChestPrizeConfig } from "./codegen/tables/ChestPrizeConfig.sol";
import { LeaderboardPosition } from "./codegen/common.sol";

contract ChestPrizeProgram is ITransfer, System, BaseProgram {
  error VotingNotEnded();
  error NotWinner();
  error NoSubmissions();
  error ChestNotConfigured();
  error DepositNotAllowed();

  function onTransfer(HookContext calldata ctx, TransferData calldata transfer) external view onlyWorld {
    if (!ctx.revertOnFailure) return;

    // Only allow withdrawals, no deposits
    if (transfer.deposits.length > 0) {
      revert DepositNotAllowed();
    }

    // Check if voting period has ended
    uint32 votingEndTimestamp = Config.getVotingEndTimestamp();
    if (block.timestamp <= votingEndTimestamp) {
      revert VotingNotEnded();
    }

    // Get the chest's configured position
    LeaderboardPosition position = ChestPrizeConfig.getPosition(ctx.target);

    // Check if chest is configured (not Unset)
    if (position == LeaderboardPosition.Unset) {
      revert ChestNotConfigured();
    }

    // Get player address
    address player = ctx.caller.getPlayerAddress();

    // Get the winner for this chest's configured position
    address winner = _getWinnerAtPosition(position);

    // Check if the player is the winner
    if (player != winner) {
      revert NotWinner();
    }

    // If we reach here, the player is allowed to withdraw everything from the chest
  }

  function _getWinnerAtPosition(LeaderboardPosition position) internal view returns (address) {
    address[] memory creators = SubmissionCreators.get();

    if (creators.length == 0) {
      revert NoSubmissions();
    }

    // Sort creators by votes using a simple bubble sort (fine for small arrays)
    for (uint256 i = 0; i < creators.length; i++) {
      for (uint256 j = i + 1; j < creators.length; j++) {
        if (Submissions.getVotesReceived(creators[i]) < Submissions.getVotesReceived(creators[j])) {
          address temp = creators[i];
          creators[i] = creators[j];
          creators[j] = temp;
        }
      }
    }

    // Convert enum position to array index (First = 1 -> index 0, Second = 2 -> index 1, etc.)
    uint256 index = uint256(position) - 1;

    // Return the winner at the specified position (if it exists)
    if (index >= creators.length) {
      return address(0); // No winner at this position
    }

    return creators[index];
  }

  // Required due to inheriting from System and WorldConsumer
  function _msgSender() public view override(WorldContextConsumer, BaseProgram) returns (address) {
    return BaseProgram._msgSender();
  }

  function _msgValue() public view override(WorldContextConsumer, BaseProgram) returns (uint256) {
    return BaseProgram._msgValue();
  }
}
