// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { HACKATHON_NAMESPACE_ID } from "../src/common.sol";
import { votingSystem } from "../src/codegen/systems/VotingSystemLib.sol";
import { Submissions, SubmissionsData } from "../src/codegen/tables/Submissions.sol";
import { Participants, ParticipantsData } from "../src/codegen/tables/Participants.sol";
import { Moderators } from "../src/codegen/tables/Moderators.sol";
import { Config, ConfigData } from "../src/codegen/tables/Config.sol";
import { Votes } from "../src/codegen/tables/Votes.sol";

contract VotingSystemTest is MudTest {
  IWorld world;
  address owner;
  address moderator1;
  address moderator2;
  address participant1;
  address participant2;
  address participant3;
  address participant4;
  address nonParticipant;
  address namespaceOwner;

  function setUp() public override {
    super.setUp();
    
    // Get world instance
    world = IWorld(worldAddress);
    
    // Set up test accounts
    owner = address(this);
    moderator1 = address(0x1);
    moderator2 = address(0x2);
    participant1 = address(0x3);
    participant2 = address(0x4);
    participant3 = address(0x5);
    participant4 = address(0x6);
    nonParticipant = address(0x7);

    // The namespace owner should be whoever deployed the contracts
    // In a forked environment, we need to impersonate the actual namespace owner
    // For now, let's assume the test contract itself has permissions
    namespaceOwner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // Common test address in Foundry
  }

  function test_OnlyNamespaceOwnerCanAddModerators() public {
    // Namespace owner should be able to add moderator
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    assertTrue(Moderators.getIsModerator(moderator1), "Moderator1 should be registered");

    // Non-owner should not be able to add moderator
    vm.prank(participant1);
    vm.expectRevert();
    votingSystem.setModerator(moderator2, true);
    
    assertFalse(Moderators.getIsModerator(moderator2), "Moderator2 should not be registered");
  }

  function test_OnlyModeratorCanSetVotingConfig() public {
    // Set up a moderator
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);

    // Moderator should be able to set config
    vm.prank(moderator1);
    votingSystem.setConfig(1000, 2000, 3);
    
    ConfigData memory config = Config.get();
    assertEq(config.votingStartTimestamp, 1000, "Voting start timestamp should be 1000");
    assertEq(config.votingEndTimestamp, 2000, "Voting end timestamp should be 2000");
    assertEq(config.votesPerParticipant, 3, "Votes per participant should be 3");

    // Non-moderator should not be able to set config
    vm.prank(participant1);
    vm.expectRevert(abi.encodeWithSignature("AccessDenied(address)", participant1));
    votingSystem.setConfig(3000, 4000, 5);
  }

  function test_OnlyModeratorCanRegisterParticipants() public {
    // Set up a moderator
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);

    // Moderator should be able to register participant
    vm.prank(moderator1);
    votingSystem.registerParticipant(participant1);
    
    assertTrue(Participants.getIsParticipant(participant1), "Participant1 should be registered");
    assertEq(Participants.getVotesGiven(participant1), 0, "Participant1 should have 0 votes given");

    // Non-moderator should not be able to register participant
    vm.prank(participant1);
    vm.expectRevert(abi.encodeWithSignature("AccessDenied(address)", participant2));
    votingSystem.registerParticipant(participant2);
    
    assertFalse(Participants.getIsParticipant(participant2), "Participant2 should not be registered");
  }

  function test_OnlyParticipantsCanSubmitProjects() public {
    // Set up moderator and participants
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    vm.prank(moderator1);
    votingSystem.registerParticipant(participant1);

    // Participant should be able to create submission
    vm.prank(participant1);
    votingSystem.createSubmission("My Project", "https://github.com/test", "https://youtube.com/test");
    
    SubmissionsData memory submission = Submissions.get(participant1);
    assertEq(submission.name, "My Project", "Submission name should match");
    assertEq(submission.githubUrl, "https://github.com/test", "GitHub URL should match");
    assertEq(submission.demoVideoUrl, "https://youtube.com/test", "Demo video URL should match");
    assertGt(submission.submittedTimestamp, 0, "Submission timestamp should be set");
    assertEq(submission.votesReceived, 0, "Initial votes should be 0");

    // Non-participant should not be able to create submission
    vm.prank(nonParticipant);
    vm.expectRevert(abi.encodeWithSignature("NotParticipant(address)", nonParticipant));
    votingSystem.createSubmission("Another Project", "https://github.com/test2", "https://youtube.com/test2");
  }

  function test_ParticipantsCannotSubmitTwice() public {
    // Set up moderator and participant
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    vm.prank(moderator1);
    votingSystem.registerParticipant(participant1);

    // First submission should succeed
    vm.prank(participant1);
    votingSystem.createSubmission("My Project", "https://github.com/test", "https://youtube.com/test");

    // Second submission should fail
    vm.prank(participant1);
    vm.expectRevert(abi.encodeWithSignature("AlreadySubmitted(address)", participant1));
    votingSystem.createSubmission("Another Project", "https://github.com/test2", "https://youtube.com/test2");
  }

  function test_ParticipantsCanUpdateSubmissionFields() public {
    // Set up moderator and participant with submission
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    vm.prank(moderator1);
    votingSystem.registerParticipant(participant1);
    
    vm.prank(participant1);
    votingSystem.createSubmission("Initial Name", "https://github.com/initial", "https://youtube.com/initial");

    // Update name
    vm.prank(participant1);
    votingSystem.updateName("Updated Name");
    assertEq(Submissions.getName(participant1), "Updated Name", "Name should be updated");

    // Update GitHub URL
    vm.prank(participant1);
    votingSystem.updateGithubUrl("https://github.com/updated");
    assertEq(Submissions.getGithubUrl(participant1), "https://github.com/updated", "GitHub URL should be updated");

    // Update demo video URL
    vm.prank(participant1);
    votingSystem.updateDemoVideoUrl("https://youtube.com/updated");
    assertEq(Submissions.getDemoVideoUrl(participant1), "https://youtube.com/updated", "Demo video URL should be updated");
  }

  function test_OnlySubmissionCreatorCanUpdateFields() public {
    // Set up moderator and two participants
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    vm.stopPrank();
    
    // Participant1 creates submission
    vm.prank(participant1);
    votingSystem.createSubmission("My Project", "https://github.com/test", "https://youtube.com/test");

    // Participant2 should not be able to update participant1's submission
    vm.prank(participant2);
    vm.expectRevert(abi.encodeWithSignature("NotFound(address)", participant2));
    votingSystem.updateName("Hacked Name");
  }

  function test_OnlyParticipantsCanVote() public {
    // Set up moderator, config, and participants
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    vm.prank(moderator1);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 1000), 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    vm.stopPrank();
    
    // Create submission
    vm.prank(participant1);
    votingSystem.createSubmission("My Project", "https://github.com/test", "https://youtube.com/test");

    // Participant should be able to vote
    vm.prank(participant2);
    votingSystem.vote(participant1);
    assertEq(Submissions.getVotesReceived(participant1), 1, "Submission should have 1 vote");

    // Non-participant should not be able to vote
    vm.prank(nonParticipant);
    vm.expectRevert(abi.encodeWithSignature("NotParticipant(address)", nonParticipant));
    votingSystem.vote(participant1);
  }

  function test_ParticipantsCanOnlyVoteUpToMaxVotes() public {
    // Set up with 2 votes per participant
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    vm.prank(moderator1);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 1000), 2);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    votingSystem.registerParticipant(participant3);
    votingSystem.registerParticipant(participant4);
    vm.stopPrank();
    
    // Create submissions
    vm.prank(participant1);
    votingSystem.createSubmission("Project 1", "url1", "video1");
    vm.prank(participant2);
    votingSystem.createSubmission("Project 2", "url2", "video2");
    vm.prank(participant3);
    votingSystem.createSubmission("Project 3", "url3", "video3");

    // Participant4 votes for two projects (allowed)
    vm.startPrank(participant4);
    votingSystem.vote(participant1);
    votingSystem.vote(participant2);
    
    // Third vote should fail
    vm.expectRevert(abi.encodeWithSignature("NoVotesLeft(address,uint32,uint32)", participant4, 2, 2));
    votingSystem.vote(participant3);
    vm.stopPrank();

    assertEq(Participants.getVotesGiven(participant4), 2, "Participant4 should have given 2 votes");
  }

  function test_VotesAreCalculatedCorrectly() public {
    // Set up
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    vm.prank(moderator1);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 1000), 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    votingSystem.registerParticipant(participant3);
    votingSystem.registerParticipant(participant4);
    vm.stopPrank();
    
    // Create submissions
    vm.prank(participant1);
    votingSystem.createSubmission("Project 1", "url1", "video1");
    vm.prank(participant2);
    votingSystem.createSubmission("Project 2", "url2", "video2");

    // Multiple participants vote
    vm.prank(participant3);
    votingSystem.vote(participant1); // participant1: 1 vote
    
    vm.prank(participant4);
    votingSystem.vote(participant1); // participant1: 2 votes
    
    vm.prank(participant3);
    votingSystem.vote(participant2); // participant2: 1 vote

    // Check vote counts
    assertEq(Submissions.getVotesReceived(participant1), 2, "Participant1 should have 2 votes");
    assertEq(Submissions.getVotesReceived(participant2), 1, "Participant2 should have 1 vote");
    assertEq(Participants.getVotesGiven(participant3), 2, "Participant3 should have given 2 votes");
    assertEq(Participants.getVotesGiven(participant4), 1, "Participant4 should have given 1 vote");
    
    // Check individual vote records
    assertEq(Votes.getVotesGiven(participant3, participant1), 1, "Participant3 -> Participant1 should be 1 vote");
    assertEq(Votes.getVotesGiven(participant3, participant2), 1, "Participant3 -> Participant2 should be 1 vote");
    assertEq(Votes.getVotesGiven(participant4, participant1), 1, "Participant4 -> Participant1 should be 1 vote");
  }

  function test_ParticipantsCanRevokeVotes() public {
    // Set up
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    vm.prank(moderator1);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 1000), 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    votingSystem.registerParticipant(participant3);
    vm.stopPrank();
    
    // Create submissions
    vm.prank(participant1);
    votingSystem.createSubmission("Project 1", "url1", "video1");
    vm.prank(participant2);
    votingSystem.createSubmission("Project 2", "url2", "video2");

    // Participant3 votes for both
    vm.startPrank(participant3);
    votingSystem.vote(participant1);
    votingSystem.vote(participant2);
    vm.stopPrank();

    assertEq(Submissions.getVotesReceived(participant1), 1, "Participant1 should have 1 vote");
    assertEq(Participants.getVotesGiven(participant3), 2, "Participant3 should have given 2 votes");

    // Revoke vote for participant1
    vm.prank(participant3);
    votingSystem.revokeVote(participant1);

    assertEq(Submissions.getVotesReceived(participant1), 0, "Participant1 should have 0 votes after revoke");
    assertEq(Submissions.getVotesReceived(participant2), 1, "Participant2 should still have 1 vote");
    assertEq(Participants.getVotesGiven(participant3), 1, "Participant3 should have given 1 vote after revoke");
    assertEq(Votes.getVotesGiven(participant3, participant1), 0, "Vote record should be 0");
  }

  function test_CannotRevokeNonExistentVote() public {
    // Set up
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    vm.prank(moderator1);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 1000), 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    vm.stopPrank();
    
    // Create submission
    vm.prank(participant1);
    votingSystem.createSubmission("Project 1", "url1", "video1");

    // Try to revoke without voting first
    vm.prank(participant2);
    vm.expectRevert(abi.encodeWithSignature("NoVotesToRevoke(address,uint32)", participant2, 0));
    votingSystem.revokeVote(participant1);
  }

  function test_VotingOnlyPossibleInVotingPeriod() public {
    // Set up
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    uint32 currentTime = uint32(block.timestamp);
    uint32 votingStart = currentTime + 100;
    uint32 votingEnd = votingStart + 100;
    
    vm.prank(moderator1);
    votingSystem.setConfig(votingStart, votingEnd, 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    vm.stopPrank();
    
    // Create submission
    vm.prank(participant1);
    votingSystem.createSubmission("Project 1", "url1", "video1");

    // Try to vote before voting period
    vm.prank(participant2);
    vm.expectRevert(abi.encodeWithSignature("NotInVotingPeriod(uint32,uint32,uint32)", currentTime, votingStart, votingEnd));
    votingSystem.vote(participant1);

    // Move to voting period
    vm.warp(votingStart + 1);
    
    // Now voting should work
    vm.prank(participant2);
    votingSystem.vote(participant1);
    assertEq(Submissions.getVotesReceived(participant1), 1, "Vote should be recorded");

    // Move past voting period
    vm.warp(votingEnd + 1);
    
    // Voting should fail again
    vm.prank(participant2);
    vm.expectRevert(abi.encodeWithSignature("NotInVotingPeriod(uint32,uint32,uint32)", votingEnd + 1, votingStart, votingEnd));
    votingSystem.vote(participant1);
  }

  function test_RevokeVoteAlsoChecksVotingPeriod() public {
    // Set up
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    uint32 currentTime = uint32(block.timestamp);
    uint32 votingStart = currentTime;
    uint32 votingEnd = votingStart + 100;
    
    vm.prank(moderator1);
    votingSystem.setConfig(votingStart, votingEnd, 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    vm.stopPrank();
    
    // Create submission and vote
    vm.prank(participant1);
    votingSystem.createSubmission("Project 1", "url1", "video1");
    
    vm.prank(participant2);
    votingSystem.vote(participant1);

    // Move past voting period
    vm.warp(votingEnd + 1);
    
    // Revoking should also fail outside voting period
    vm.prank(participant2);
    vm.expectRevert(abi.encodeWithSignature("NotInVotingPeriod(uint32,uint32,uint32)", votingEnd + 1, votingStart, votingEnd));
    votingSystem.revokeVote(participant1);
  }

  function test_CannotVoteForNonExistentSubmission() public {
    // Set up
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    vm.prank(moderator1);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 1000), 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    vm.stopPrank();

    // Try to vote for participant2 who hasn't submitted
    vm.prank(participant1);
    vm.expectRevert(abi.encodeWithSignature("NotFound(address)", participant2));
    votingSystem.vote(participant2);
  }

  function test_ParticipantCanVoteMultipleTimesForSameSubmission() public {
    // Set up
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    vm.prank(moderator1);
    votingSystem.setConfig(uint32(block.timestamp), uint32(block.timestamp + 1000), 3);
    
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    vm.stopPrank();
    
    // Create submission
    vm.prank(participant1);
    votingSystem.createSubmission("Project 1", "url1", "video1");

    // Participant2 votes multiple times for same submission
    vm.startPrank(participant2);
    votingSystem.vote(participant1);
    votingSystem.vote(participant1);
    votingSystem.vote(participant1);
    vm.stopPrank();

    assertEq(Submissions.getVotesReceived(participant1), 3, "Participant1 should have 3 votes");
    assertEq(Participants.getVotesGiven(participant2), 3, "Participant2 should have given 3 votes");
    assertEq(Votes.getVotesGiven(participant2, participant1), 3, "Vote record should show 3 votes");
  }

  function test_RemovingModeratorPrivileges() public {
    // Add moderator
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    assertTrue(Moderators.getIsModerator(moderator1), "Should be moderator");

    // Moderator can set config
    vm.prank(moderator1);
    votingSystem.setConfig(1000, 2000, 3);

    // Remove moderator privileges
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, false);
    assertFalse(Moderators.getIsModerator(moderator1), "Should not be moderator");

    // Ex-moderator cannot set config anymore
    vm.prank(moderator1);
    vm.expectRevert(abi.encodeWithSignature("AccessDenied(address)", moderator1));
    votingSystem.setConfig(3000, 4000, 5);
  }

  function test_CompleteVotingScenario() public {
    // Setup phase
    vm.prank(namespaceOwner);
    votingSystem.setModerator(moderator1, true);
    
    uint32 votingStart = uint32(block.timestamp);
    uint32 votingEnd = votingStart + 1000;
    
    vm.prank(moderator1);
    votingSystem.setConfig(votingStart, votingEnd, 2);
    
    // Register 4 participants
    vm.startPrank(moderator1);
    votingSystem.registerParticipant(participant1);
    votingSystem.registerParticipant(participant2);
    votingSystem.registerParticipant(participant3);
    votingSystem.registerParticipant(participant4);
    vm.stopPrank();
    
    // Submission phase - 3 participants submit projects
    vm.prank(participant1);
    votingSystem.createSubmission("DeFi Protocol", "https://github.com/defi", "https://youtube.com/defi");
    
    vm.prank(participant2);
    votingSystem.createSubmission("NFT Marketplace", "https://github.com/nft", "https://youtube.com/nft");
    
    vm.prank(participant3);
    votingSystem.createSubmission("Gaming Platform", "https://github.com/gaming", "https://youtube.com/gaming");

    // Voting phase
    // Participant1 votes for projects 2 and 3
    vm.startPrank(participant1);
    votingSystem.vote(participant2);
    votingSystem.vote(participant3);
    vm.stopPrank();
    
    // Participant2 votes for project 1 twice
    vm.startPrank(participant2);
    votingSystem.vote(participant1);
    votingSystem.vote(participant1);
    vm.stopPrank();
    
    // Participant3 votes for project 1 once, then changes mind
    vm.startPrank(participant3);
    votingSystem.vote(participant1);
    votingSystem.revokeVote(participant1);
    votingSystem.vote(participant2);
    vm.stopPrank();
    
    // Participant4 votes for project 2
    vm.prank(participant4);
    votingSystem.vote(participant2);

    // Verify final results
    assertEq(Submissions.getVotesReceived(participant1), 2, "Project 1 should have 2 votes");
    assertEq(Submissions.getVotesReceived(participant2), 3, "Project 2 should have 3 votes");
    assertEq(Submissions.getVotesReceived(participant3), 1, "Project 3 should have 1 vote");
    
    // Verify vote counts per participant
    assertEq(Participants.getVotesGiven(participant1), 2, "Participant1 gave 2 votes");
    assertEq(Participants.getVotesGiven(participant2), 2, "Participant2 gave 2 votes");
    assertEq(Participants.getVotesGiven(participant3), 1, "Participant3 gave 1 vote");
    assertEq(Participants.getVotesGiven(participant4), 1, "Participant4 gave 1 vote");
  }
}