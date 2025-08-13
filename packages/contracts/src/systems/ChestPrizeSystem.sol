// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { EntityId } from "@dust/world/src/types/EntityId.sol";
import { Moderators } from "../codegen/tables/Moderators.sol";
import { ChestPrizeConfig } from "../codegen/tables/ChestPrizeConfig.sol";
import { LeaderboardPosition } from "../codegen/common.sol";

contract ChestPrizeSystem is System {
  error NotModerator(address user);
  error InvalidPosition();

  /// @notice Configure a chest to be claimable by a specific leaderboard position
  /// @param chest The EntityId of the chest
  /// @param position The position on the leaderboard (First, Second, or Third)
  function configureChest(EntityId chest, LeaderboardPosition position) public {
    if (!Moderators.getIsModerator(_msgSender())) {
      revert NotModerator(_msgSender());
    }

    if (position == LeaderboardPosition.Unset) {
      revert InvalidPosition();
    }

    ChestPrizeConfig.set(chest, position);
  }

  /// @notice Remove configuration from a chest (set to Unset)
  /// @param chest The EntityId of the chest
  function removeChestConfig(EntityId chest) public {
    if (!Moderators.getIsModerator(_msgSender())) {
      revert NotModerator(_msgSender());
    }

    ChestPrizeConfig.set(chest, LeaderboardPosition.Unset);
  }
}
