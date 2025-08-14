// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { HookContext, ITransfer, SlotData } from "@dust/world/src/ProgramHooks.sol";
import { EntityId, EntityTypeLib } from "@dust/world/src/types/EntityId.sol";
import { ObjectType, ObjectTypes } from "@dust/world/src/types/ObjectType.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { ChestPrizeProgram } from "../src/ChestPrizeProgram.sol";
import { Constants } from "../src/Constants.sol";

import { chestPrizeProgram } from "../src/codegen/systems/ChestPrizeProgramLib.sol";
import { chestPrizeSystem } from "../src/codegen/systems/ChestPrizeSystemLib.sol";
import { votingSystem } from "../src/codegen/systems/VotingSystemLib.sol";
import { Config } from "../src/codegen/tables/Config.sol";
import { Submissions } from "../src/codegen/tables/Submissions.sol";
import { SubmissionCreators } from "../src/codegen/tables/SubmissionCreators.sol";
import { ChestPrizeConfig } from "../src/codegen/tables/ChestPrizeConfig.sol";
import { LeaderboardPosition } from "../src/codegen/common.sol";

contract ChestPrizeProgramTest is MudTest {
  IWorld world;
  ChestPrizeProgram program;

  EntityId chest1;
  EntityId chest2;
  EntityId chest3;
  EntityId player1;
  EntityId player2;
  EntityId player3;
  EntityId player4;

  address winner1;
  address winner2;
  address winner3;
  address nonWinner;
  address moderator;
  address namespaceOwner;

  function setUp() public override {
    super.setUp();

    // Get world instance
    world = IWorld(worldAddress);

    // Deploy the programs
    program = ChestPrizeProgram(chestPrizeProgram.getAddress());

    bytes32 worldSlot = keccak256("mud.store.storage.StoreSwitch");
    bytes32 worldAddressBytes32 = bytes32(uint256(uint160(worldAddress)));
    vm.store(address(program), worldSlot, worldAddressBytes32);

    // Create test entities
    chest1 = EntityId.wrap(bytes32(uint256(1)));
    chest2 = EntityId.wrap(bytes32(uint256(2)));
    chest3 = EntityId.wrap(bytes32(uint256(3)));

    // Set up test accounts
    winner1 = address(0x1);
    winner2 = address(0x2);
    winner3 = address(0x3);
    nonWinner = address(0x4);
    moderator = address(0x5);
    namespaceOwner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

    player1 = EntityTypeLib.encodePlayer(winner1);
    player2 = EntityTypeLib.encodePlayer(winner2);
    player3 = EntityTypeLib.encodePlayer(winner3);
    player4 = EntityTypeLib.encodePlayer(nonWinner);

    // Set up namespace owner and moderator
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator, true);

    // Set up voting config with voting period active
    vm.prank(moderator);
    votingSystem.setConfig(uint32(block.timestamp - 200), uint32(block.timestamp + 100), 3);

    // Register participants
    vm.startPrank(moderator);
    votingSystem.registerParticipant(winner1);
    votingSystem.registerParticipant(winner2);
    votingSystem.registerParticipant(winner3);
    votingSystem.registerParticipant(nonWinner);
    vm.stopPrank();

    // Create submissions
    vm.prank(winner1);
    votingSystem.createSubmission("First Place", "github1", "video1");

    vm.prank(winner2);
    votingSystem.createSubmission("Second Place", "github2", "video2");

    vm.prank(winner3);
    votingSystem.createSubmission("Third Place", "github3", "video3");

    // Vote to establish leaderboard
    // Winner1 gets 3 votes
    vm.prank(winner2);
    votingSystem.vote(winner1);
    vm.prank(winner3);
    votingSystem.vote(winner1);
    vm.prank(nonWinner);
    votingSystem.vote(winner1);

    // Winner2 gets 2 votes
    vm.prank(winner1);
    votingSystem.vote(winner2);
    vm.prank(winner3);
    votingSystem.vote(winner2);

    // Winner3 gets 1 vote
    vm.prank(winner1);
    votingSystem.vote(winner3);

    // Move time forward to end voting
    vm.warp(block.timestamp + 200);
  }

  function test_ChestPrizeSystem_OnlyModeratorCanConfigureChest() public {
    // Moderator should be able to configure chest
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);
    assertEq(uint256(ChestPrizeConfig.getPosition(chest1)), uint256(LeaderboardPosition.First));

    // Non-moderator should not be able to configure chest
    vm.prank(nonWinner);
    vm.expectRevert(abi.encodeWithSignature("NotModerator(address)", nonWinner));
    chestPrizeSystem.configureChest(chest2, LeaderboardPosition.Second);
  }

  function test_ChestPrizeSystem_CannotSetInvalidPosition() public {
    // Cannot set position to Unset
    vm.prank(moderator);
    vm.expectRevert(abi.encodeWithSignature("InvalidPosition()"));
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.Unset);
  }

  function test_ChestPrizeSystem_CanRemoveChestConfig() public {
    // Configure chest first
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);
    assertEq(uint256(ChestPrizeConfig.getPosition(chest1)), uint256(LeaderboardPosition.First));

    // Remove configuration
    vm.prank(moderator);
    chestPrizeSystem.removeChestConfig(chest1);
    assertEq(uint256(ChestPrizeConfig.getPosition(chest1)), uint256(LeaderboardPosition.Unset));
  }

  function test_AnyoneCanDepositToChest() public {
    // Configure chest
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);

    // Anyone should be able to deposit, even non-participants
    HookContext memory ctx = HookContext({ caller: player4, target: chest1, revertOnFailure: true, extraData: "" });

    SlotData[] memory deposits = new SlotData[](1);
    deposits[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 5 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: deposits,
      withdrawals: new SlotData[](0)
    });

    // Should not revert - deposits are allowed from anyone
    vm.prank(worldAddress);
    program.onTransfer(ctx, transfer);
  }

  function test_ModeratorCanWithdrawAnytime() public {
    // Reset voting to not ended yet
    vm.prank(moderator);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 100), 3);

    // Configure chest
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);

    // Moderator withdraws even though voting hasn't ended
    EntityId moderatorEntity = EntityTypeLib.encodePlayer(moderator);
    HookContext memory ctx = HookContext({ caller: moderatorEntity, target: chest1, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    // Should not revert - moderators can withdraw anytime
    vm.prank(worldAddress);
    program.onTransfer(ctx, transfer);
  }

  function test_CannotWithdrawBeforeVotingEnds() public {
    // Reset voting to not ended yet
    vm.prank(moderator);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 100), 3);

    // Configure chest
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);

    HookContext memory ctx = HookContext({ caller: player1, target: chest1, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    vm.prank(worldAddress);
    vm.expectRevert(abi.encodeWithSignature("VotingNotEnded()"));
    program.onTransfer(ctx, transfer);
  }

  function test_CannotWithdrawFromUnconfiguredChest() public {
    HookContext memory ctx = HookContext({ caller: player1, target: chest1, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    vm.prank(worldAddress);
    vm.expectRevert(abi.encodeWithSignature("ChestNotConfigured()"));
    program.onTransfer(ctx, transfer);
  }

  function test_OnlyWinnerCanWithdraw() public {
    // Configure chests for each position
    vm.startPrank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);
    chestPrizeSystem.configureChest(chest2, LeaderboardPosition.Second);
    chestPrizeSystem.configureChest(chest3, LeaderboardPosition.Third);
    vm.stopPrank();

    // Non-winner tries to withdraw from first place chest
    HookContext memory ctx = HookContext({ caller: player4, target: chest1, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    vm.prank(worldAddress);
    vm.expectRevert(abi.encodeWithSignature("NotAuthorizedToWithdraw()"));
    program.onTransfer(ctx, transfer);
  }

  function test_FirstPlaceWinnerCanWithdrawFromFirstPlaceChest() public {
    // Configure chest for first place
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);

    // First place winner withdraws
    HookContext memory ctx = HookContext({ caller: player1, target: chest1, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](2);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 100 });
    withdrawals[1] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.Dirt, amount: 50 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    // Should not revert
    vm.prank(worldAddress);
    program.onTransfer(ctx, transfer);
  }

  function test_SecondPlaceWinnerCanWithdrawFromSecondPlaceChest() public {
    // Configure chest for second place
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest2, LeaderboardPosition.Second);

    // Second place winner withdraws
    HookContext memory ctx = HookContext({ caller: player2, target: chest2, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 75 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    // Should not revert
    vm.prank(worldAddress);
    program.onTransfer(ctx, transfer);
  }

  function test_ThirdPlaceWinnerCanWithdrawFromThirdPlaceChest() public {
    // Configure chest for third place
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest3, LeaderboardPosition.Third);

    // Third place winner withdraws
    HookContext memory ctx = HookContext({ caller: player3, target: chest3, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 25 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    // Should not revert
    vm.prank(worldAddress);
    program.onTransfer(ctx, transfer);
  }

  function test_WinnersCannotWithdrawFromWrongChest() public {
    // Configure chests
    vm.startPrank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);
    chestPrizeSystem.configureChest(chest2, LeaderboardPosition.Second);
    vm.stopPrank();

    // First place winner tries to withdraw from second place chest
    HookContext memory ctx = HookContext({ caller: player1, target: chest2, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    vm.prank(worldAddress);
    vm.expectRevert(abi.encodeWithSignature("NotAuthorizedToWithdraw()"));
    program.onTransfer(ctx, transfer);
  }

  function test_NoWinnerIfNoSubmissions() public {
    // Clear all submissions by using namespace owner
    vm.prank(namespaceOwner);
    SubmissionCreators.set(new address[](0));

    // Configure chest
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);

    HookContext memory ctx = HookContext({ caller: player1, target: chest1, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    vm.prank(worldAddress);
    vm.expectRevert(abi.encodeWithSignature("NoSubmissions()"));
    program.onTransfer(ctx, transfer);
  }

  function test_HandlesFewerSubmissionsThanPositions() public {
    // Clear submissions and only add two by using namespace owner
    address[] memory twoCreators = new address[](2);
    twoCreators[0] = winner1;
    twoCreators[1] = winner2;
    vm.prank(namespaceOwner);
    SubmissionCreators.set(twoCreators);

    // Configure chest for third place (which doesn't exist)
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest3, LeaderboardPosition.Third);

    // Anyone trying to withdraw from third place chest should fail
    HookContext memory ctx = HookContext({ caller: player1, target: chest3, revertOnFailure: true, extraData: "" });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    vm.prank(worldAddress);
    vm.expectRevert(abi.encodeWithSignature("NotAuthorizedToWithdraw()"));
    program.onTransfer(ctx, transfer);
  }

  function test_NonRevertingTransfersAreIgnored() public {
    // Configure chest
    vm.prank(moderator);
    chestPrizeSystem.configureChest(chest1, LeaderboardPosition.First);

    // Non-reverting context (revertOnFailure = false)
    HookContext memory ctx = HookContext({
      caller: player4, // non-winner
      target: chest1,
      revertOnFailure: false,
      extraData: ""
    });

    SlotData[] memory withdrawals = new SlotData[](1);
    withdrawals[0] = SlotData({ entityId: EntityId.wrap(0), objectType: ObjectTypes.WheatSeed, amount: 10 });

    ITransfer.TransferData memory transfer = ITransfer.TransferData({
      deposits: new SlotData[](0),
      withdrawals: withdrawals
    });

    // Should not revert even though player4 is not a winner
    vm.prank(worldAddress);
    program.onTransfer(ctx, transfer);
  }
}
