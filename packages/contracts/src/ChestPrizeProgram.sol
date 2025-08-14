// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { HookContext, ITransfer, SlotData } from "@dust/world/src/ProgramHooks.sol";
import { System, WorldContextConsumer } from "@latticexyz/world/src/System.sol";

import { BaseProgram } from "./BaseProgram.sol";
import { Submissions } from "./codegen/tables/Submissions.sol";
import { Config } from "./codegen/tables/Config.sol";
import { SubmissionCreators } from "./codegen/tables/SubmissionCreators.sol";
import { ChestPrizeConfig } from "./codegen/tables/ChestPrizeConfig.sol";
import { Moderators } from "./codegen/tables/Moderators.sol";
import { LeaderboardPosition } from "./codegen/common.sol";

contract ChestPrizeProgram is ITransfer, System, BaseProgram {
  error VotingNotEnded();
  error NotAuthorizedToWithdraw();
  error NoSubmissions();
  error ChestNotConfigured();

  function onTransfer(HookContext calldata ctx, TransferData calldata transfer) external view onlyWorld {
    if (!ctx.revertOnFailure) return;

    // Allow anyone to deposit (no restrictions on deposits)
    
    // Only check restrictions on withdrawals
    if (transfer.withdrawals.length > 0) {
      // Get player address
      address player = ctx.caller.getPlayerAddress();
      
      // Check if player is a moderator - they can always withdraw
      if (Moderators.getIsModerator(player)) {
        return; // Moderator can withdraw at any time
      }

      // For non-moderators, check if voting has ended
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

      // Get the winner for this chest's configured position
      address winner = _getWinnerAtPosition(position);

      // Check if the player is the winner
      if (player != winner) {
        revert NotAuthorizedToWithdraw();
      }
    }

    // If we reach here, the action is allowed
  }

  function _getWinnerAtPosition(LeaderboardPosition position) internal view returns (address) {
    address[] memory creators = SubmissionCreators.get();

    if (creators.length == 0) {
      revert NoSubmissions();
    }

    // Convert enum position to target rank (First = 1 -> rank 0, Second = 2 -> rank 1, etc.)
    uint256 targetRank = uint256(position) - 1;
    
    // Return address(0) if position is beyond the number of submissions
    if (targetRank >= creators.length) {
      return address(0);
    }

    // For small fixed positions (top 3), a simple linear scan tracking top N is most efficient
    // This is O(n) with a very small constant factor and simple implementation
    
    // Track top 3 addresses and their vote counts
    address[3] memory topAddresses;
    uint32[3] memory topVotes;
    
    // Initialize with first creators (up to 3)
    uint256 initCount = creators.length < 3 ? creators.length : 3;
    for (uint256 i = 0; i < initCount; i++) {
      topAddresses[i] = creators[i];
      topVotes[i] = Submissions.getVotesReceived(creators[i]);
    }
    
    // Sort the initial top 3
    _sortTop3(topAddresses, topVotes);
    
    // Process remaining creators
    for (uint256 i = initCount; i < creators.length; i++) {
      uint32 currentVotes = Submissions.getVotesReceived(creators[i]);
      
      // Check if this creator should be in top 3
      if (currentVotes > topVotes[2]) {
        // Replace the 3rd place
        topAddresses[2] = creators[i];
        topVotes[2] = currentVotes;
        
        // Bubble up if needed to maintain sorted order
        if (currentVotes > topVotes[1]) {
          // Swap with 2nd place
          (topAddresses[2], topAddresses[1]) = (topAddresses[1], topAddresses[2]);
          (topVotes[2], topVotes[1]) = (topVotes[1], topVotes[2]);
          
          if (currentVotes > topVotes[0]) {
            // Swap with 1st place
            (topAddresses[1], topAddresses[0]) = (topAddresses[0], topAddresses[1]);
            (topVotes[1], topVotes[0]) = (topVotes[0], topVotes[1]);
          }
        }
      }
    }
    
    return topAddresses[targetRank];
  }

  /// @notice Sort an array of up to 3 elements by votes (descending)
  function _sortTop3(address[3] memory addresses, uint32[3] memory votes) internal pure {
    // Simple bubble sort for 3 elements (max 3 comparisons)
    if (votes[0] < votes[1]) {
      (addresses[0], addresses[1]) = (addresses[1], addresses[0]);
      (votes[0], votes[1]) = (votes[1], votes[0]);
    }
    if (votes[1] < votes[2]) {
      (addresses[1], addresses[2]) = (addresses[2], addresses[1]);
      (votes[1], votes[2]) = (votes[2], votes[1]);
    }
    if (votes[0] < votes[1]) {
      (addresses[0], addresses[1]) = (addresses[1], addresses[0]);
      (votes[0], votes[1]) = (votes[1], votes[0]);
    }
  }

  // Required due to inheriting from System and WorldConsumer
  function _msgSender() public view override(WorldContextConsumer, BaseProgram) returns (address) {
    return BaseProgram._msgSender();
  }

  function _msgValue() public view override(WorldContextConsumer, BaseProgram) returns (uint256) {
    return BaseProgram._msgValue();
  }
}