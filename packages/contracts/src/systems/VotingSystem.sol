// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";
import { Submissions, SubmissionsData } from "../codegen/tables/Submissions.sol";
import { Participants, ParticipantsData } from "../codegen/tables/Participants.sol";
import { Moderators } from "../codegen/tables/Moderators.sol";
import { AccessControl } from "@latticexyz/world/src/AccessControl.sol";
import { Config, ConfigData } from "../codegen/tables/Config.sol";
import { Votes } from "../codegen/tables/Votes.sol";
import { SubmissionCreators } from "../codegen/tables/SubmissionCreators.sol";
import { VoteHistory } from "../codegen/tables/VoteHistory.sol";
import { Constants } from "../Constants.sol";

contract VotingSystem is System {
  error AccessDenied(address user);
  error NotParticipant(address user);
  error AlreadySubmitted(address user);
  error NotFound(address creator);
  error NotInVotingPeriod(uint32 timestamp, uint32 votingStartTimestamp, uint32 votingEndTimestamp);
  error NoVotesLeft(address user, uint32 votesGiven, uint32 votesPerParticipant);
  error NoVotesToRevoke(address user, uint32 votesGiven);

  /// @notice Register a moderator. Only the namespace owner can register moderators
  /// @param user The address of the user to register as a moderator
  /// @param isModerator Whether the user is a moderator
  function setModerator(address user, bool isModerator) public {
    AccessControl.requireAccess(Constants.NAMESPACE_ID, _msgSender());
    Moderators.set({ user: user, isModerator: isModerator });
  }

  /// @notice Set the voting configuration. Only moderators can set the voting configuration
  /// @param votingStartTimestamp The start timestamp of the voting period
  /// @param votingEndTimestamp The end timestamp of the voting period
  /// @param votesPerParticipant The number of votes each participant can give
  function setConfig(uint32 votingStartTimestamp, uint32 votingEndTimestamp, uint32 votesPerParticipant) public {
    if (!Moderators.getIsModerator(_msgSender())) {
      revert AccessDenied(_msgSender());
    }

    Config.set({
      votingStartTimestamp: votingStartTimestamp,
      votingEndTimestamp: votingEndTimestamp,
      votesPerParticipant: votesPerParticipant
    });
  }

  /// @notice Register a participant. Only moderators can register participants
  /// @param user The address of the user to register as a participant
  function registerParticipant(address user) public {
    if (!Moderators.getIsModerator(_msgSender())) {
      revert AccessDenied(user);
    }

    Participants.set(user, ParticipantsData({ isParticipant: true, votesGiven: 0 }));
  }

  /// @notice Create a submission. Only participants can create submissions
  /// @param name The name of the submission
  /// @param githubUrl The URL of the submission's GitHub repository
  /// @param demoVideoUrl The URL of the submission's demo video
  function createSubmission(string memory name, string memory githubUrl, string memory demoVideoUrl) public {
    address user = _msgSender();

    if (!Participants.getIsParticipant(_msgSender())) {
      revert NotParticipant(_msgSender());
    }

    if (Submissions.getSubmittedTimestamp(user) > 0) {
      revert AlreadySubmitted(user);
    }

    Submissions.set(
      _msgSender(),
      SubmissionsData({
        submittedTimestamp: uint32(block.timestamp),
        votesReceived: 0,
        name: name,
        githubUrl: githubUrl,
        demoVideoUrl: demoVideoUrl
      })
    );

    SubmissionCreators.push(user);
  }

  /// @notice Update the name of a submission. Only the submission creator can update the name
  /// @param name The new name
  function updateName(string memory name) public {
    address user = _msgSender();

    if (Submissions.getSubmittedTimestamp(user) == 0) {
      revert NotFound(user);
    }

    Submissions.setName({ creator: user, name: name });
  }

  /// @notice Update the GitHub URL of a submission. Only the submission creator can update the GitHub URL
  /// @param githubUrl The new GitHub URL
  function updateGithubUrl(string memory githubUrl) public {
    address user = _msgSender();

    if (Submissions.getSubmittedTimestamp(user) == 0) {
      revert NotFound(user);
    }

    Submissions.setGithubUrl({ creator: user, githubUrl: githubUrl });
  }

  /// @notice Update the demo video URL of a submission. Only the submission creator can update the demo video URL
  /// @param demoVideoUrl The new demo video URL
  function updateDemoVideoUrl(string memory demoVideoUrl) public {
    address user = _msgSender();

    if (Submissions.getSubmittedTimestamp(user) == 0) {
      revert NotFound(user);
    }

    Submissions.setDemoVideoUrl({ creator: user, demoVideoUrl: demoVideoUrl });
  }

  /// @notice Vote for a submission. Only participants can vote.
  /// @param creator The address of the submission creator
  function vote(address creator) public {
    address caller = _msgSender();

    _requireValidVote(caller, creator);

    ConfigData memory config = Config.get();

    uint32 totalVotesGiven = Participants.getVotesGiven(caller);
    if (totalVotesGiven >= config.votesPerParticipant) {
      revert NoVotesLeft(caller, totalVotesGiven, config.votesPerParticipant);
    }

    uint32 submissionVotesGiven = Votes.getVotesGiven(caller, creator);
    uint32 submissionVotesReceived = Submissions.getVotesReceived(creator);

    Votes.set({ voter: caller, submission: creator, votesGiven: submissionVotesGiven + 1 });
    Participants.setVotesGiven({ user: caller, votesGiven: totalVotesGiven + 1 });
    Submissions.setVotesReceived({ creator: creator, votesReceived: submissionVotesReceived + 1 });
    VoteHistory.set({
      voter: caller,
      submission: creator,
      timestamp: uint32(block.timestamp),
      diff: 1,
      totalVotes: submissionVotesReceived + 1
    });
  }

  /// @notice Revoke a vote for a submission. Only participants who have voted can revoke votes.
  /// @param creator The address of the submission creator
  function revokeVote(address creator) public {
    address caller = _msgSender();

    _requireValidVote(caller, creator);

    uint32 submissionVotesGiven = Votes.getVotesGiven(caller, creator);
    if (submissionVotesGiven == 0) {
      revert NoVotesToRevoke(caller, submissionVotesGiven);
    }

    uint32 submissionVotesReceived = Submissions.getVotesReceived(creator);

    Votes.set({ voter: caller, submission: creator, votesGiven: submissionVotesGiven - 1 });
    Participants.setVotesGiven({ user: caller, votesGiven: Participants.getVotesGiven(caller) - 1 });
    Submissions.setVotesReceived({ creator: creator, votesReceived: submissionVotesReceived - 1 });
    VoteHistory.set({
      voter: caller,
      submission: creator,
      timestamp: uint32(block.timestamp),
      diff: -1,
      totalVotes: submissionVotesReceived - 1
    });
  }

  function _requireValidVote(address caller, address creator) internal view {
    if (!Participants.getIsParticipant(caller)) {
      revert NotParticipant(caller);
    }

    if (Submissions.getSubmittedTimestamp(creator) == 0) {
      revert NotFound(creator);
    }

    ConfigData memory config = Config.get();

    if (block.timestamp < config.votingStartTimestamp || block.timestamp > config.votingEndTimestamp) {
      revert NotInVotingPeriod(uint32(block.timestamp), config.votingStartTimestamp, config.votingEndTimestamp);
    }
  }
}
