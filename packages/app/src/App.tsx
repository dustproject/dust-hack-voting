import { usePlayerStatus } from "./common/usePlayerStatus";
import { useSyncStatus } from "./mud/useSyncStatus";
import { useDustClient } from "./common/useDustClient";
import { stash, tables } from "./mud/stash";
import { useRecords, useRecord } from "@latticexyz/stash/react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { resourceToHex } from "@latticexyz/common";
import mudConfig from "contracts/mud.config";
import VotingSystemAbi from "contracts/out/VotingSystem.sol/VotingSystem.abi.json";
import { useState, useMemo } from "react";
import { AccountName } from "./common/AccountName";

interface Submission {
  creator: string;
  name: string;
  githubUrl: string;
  demoVideoUrl: string;
  votesReceived: number;
  submittedTimestamp: number;
}

export default function App() {
  const { data: dustClient } = useDustClient();
  const syncStatus = useSyncStatus();
  const playerStatus = usePlayerStatus();
  const queryClient = useQueryClient();

  const [activeTab, setActiveTab] = useState<"submit" | "projects">("projects");
  const [formData, setFormData] = useState({
    name: "",
    githubUrl: "",
    demoVideoUrl: "",
  });

  // Get current user's participant status
  const currentUserParticipant = useRecord({
    stash,
    table: tables.Participants,
    key: { user: dustClient?.appContext.userAddress || "0x0" },
  });

  // Get all submissions
  const submissionsRecords = useRecords({
    stash,
    table: tables.Submissions,
  });

  // Get voting config
  const config = useRecord({
    stash,
    table: tables.Config,
    key: {},
  });

  // Get user's votes
  const userVotes = useRecords({
    stash,
    table: tables.Votes,
  });

  // Process submissions data
  const submissions = useMemo(() => {
    const subs: Submission[] = [];
    if (submissionsRecords) {
      for (const sub of submissionsRecords) {
        if (sub) {
          subs.push({
            creator: sub.creator,
            name: sub.name,
            githubUrl: sub.githubUrl,
            demoVideoUrl: sub.demoVideoUrl,
            votesReceived: sub.votesReceived,
            submittedTimestamp: sub.submittedTimestamp,
          });
        }
      }
    }
    // Sort by votes (descending)
    return subs.sort((a, b) => b.votesReceived - a.votesReceived);
  }, [submissionsRecords]);

  // Check if user has already submitted
  const userSubmission = submissions.find(
    (s) => s.creator === dustClient?.appContext.userAddress
  );

  // Get user's votes for each submission
  const getUserVotesForSubmission = (creator: string) => {
    if (!userVotes || !dustClient) return 0;
    for (const vote of userVotes) {
      if (
        vote.voter === dustClient.appContext.userAddress &&
        vote.submission === creator
      ) {
        return vote.votesGiven || 0;
      }
    }
    return 0;
  };

  // Create submission mutation
  const createSubmission = useMutation({
    mutationFn: async () => {
      if (!dustClient) throw new Error("Dust client not connected");
      return dustClient.provider.request({
        method: "systemCall",
        params: [
          {
            systemId: resourceToHex({
              type: "system",
              namespace: mudConfig.namespace,
              name: "VotingSystem",
            }),
            abi: VotingSystemAbi,
            functionName: "createSubmission",
            args: [formData.name, formData.githubUrl, formData.demoVideoUrl],
          },
        ],
      });
    },
    onSuccess: () => {
      setFormData({ name: "", githubUrl: "", demoVideoUrl: "" });
      setActiveTab("projects");
      queryClient.invalidateQueries();
    },
  });

  // Vote mutation
  const vote = useMutation({
    mutationFn: async (creator: string) => {
      if (!dustClient) throw new Error("Dust client not connected");
      return dustClient.provider.request({
        method: "systemCall",
        params: [
          {
            systemId: resourceToHex({
              type: "system",
              namespace: mudConfig.namespace,
              name: "VotingSystem",
            }),
            abi: VotingSystemAbi,
            functionName: "vote",
            args: [creator],
          },
        ],
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries();
    },
  });

  // Revoke vote mutation
  const revokeVote = useMutation({
    mutationFn: async (creator: string) => {
      if (!dustClient) throw new Error("Dust client not connected");
      return dustClient.provider.request({
        method: "systemCall",
        params: [
          {
            systemId: resourceToHex({
              type: "system",
              namespace: mudConfig.namespace,
              name: "VotingSystem",
            }),
            abi: VotingSystemAbi,
            functionName: "revokeVote",
            args: [creator],
          },
        ],
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries();
    },
  });

  if (!dustClient) {
    const url = `https://alpha.dustproject.org?debug-app=${window.location.origin}/dust-app.json`;
    return (
      <div className="flex flex-col h-screen items-center justify-center bg-gray-50">
        <a
          href={url}
          className="text-center text-blue-600 underline hover:text-blue-800"
        >
          Open this page in DUST to connect to dustkit
        </a>
      </div>
    );
  }

  if (!syncStatus.isLive || !playerStatus) {
    return (
      <div className="flex flex-col h-screen items-center justify-center bg-gray-50">
        <p className="text-center text-gray-600">
          Syncing ({syncStatus.percentage}%)...
        </p>
      </div>
    );
  }

  const isParticipant = currentUserParticipant?.isParticipant;
  const votesGiven = currentUserParticipant?.votesGiven ?? 0;
  const votesPerParticipant = config?.votesPerParticipant ?? 0;
  const votesRemaining = Math.max(0, votesPerParticipant - votesGiven);

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto p-6">
        {/* Header */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            DUST Hackathon Voting
          </h1>
          <div className="text-sm text-gray-600">
            <p>
              Logged in as:{" "}
              <AccountName address={dustClient.appContext.userAddress} />
            </p>
            {isParticipant && (
              <p className="mt-1">
                Votes remaining: {votesRemaining} / {votesPerParticipant}
              </p>
            )}
          </div>
        </div>

        {/* Not a participant warning */}
        {!isParticipant && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
            <p className="text-yellow-800">
              You are not registered as a participant. Contact a moderator to
              get access.
            </p>
          </div>
        )}

        {/* Tabs */}
        {isParticipant && (
          <div className="flex space-x-1 mb-6">
            <button
              onClick={() => setActiveTab("projects")}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                activeTab === "projects"
                  ? "bg-gray-900 text-white"
                  : "bg-white text-gray-600 hover:bg-gray-100"
              }`}
            >
              Projects ({submissions.length})
            </button>
            <button
              onClick={() => setActiveTab("submit")}
              disabled={!!userSubmission}
              className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                activeTab === "submit"
                  ? "bg-gray-900 text-white"
                  : userSubmission
                    ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                    : "bg-white text-gray-600 hover:bg-gray-100"
              }`}
            >
              {userSubmission ? "Already Submitted" : "Submit Project"}
            </button>
          </div>
        )}

        {/* Content */}
        {activeTab === "submit" && isParticipant && !userSubmission && (
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Submit Your Project
            </h2>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                createSubmission.mutate();
              }}
              className="space-y-4"
            >
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Project Name
                </label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) =>
                    setFormData({ ...formData, name: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
                  placeholder="My Awesome DUST Project"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  GitHub Repository URL
                </label>
                <input
                  type="url"
                  required
                  value={formData.githubUrl}
                  onChange={(e) =>
                    setFormData({ ...formData, githubUrl: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
                  placeholder="https://github.com/username/repo"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Demo Video URL
                </label>
                <input
                  type="url"
                  required
                  value={formData.demoVideoUrl}
                  onChange={(e) =>
                    setFormData({ ...formData, demoVideoUrl: e.target.value })
                  }
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
                  placeholder="https://youtube.com/watch?v=..."
                />
              </div>
              <button
                type="submit"
                disabled={createSubmission.isPending}
                className="w-full bg-gray-900 text-white py-2 px-4 rounded-lg hover:bg-gray-800 disabled:bg-gray-400 transition-colors"
              >
                {createSubmission.isPending
                  ? "Submitting..."
                  : "Submit Project"}
              </button>
            </form>
          </div>
        )}

        {activeTab === "projects" && (
          <div className="space-y-4">
            {submissions.length === 0 ? (
              <div className="bg-white rounded-lg shadow-sm p-8 text-center text-gray-500">
                No projects submitted yet
              </div>
            ) : (
              submissions.map((submission, index) => {
                const userVotesForThis = getUserVotesForSubmission(
                  submission.creator
                );
                const isOwnSubmission =
                  submission.creator === dustClient.appContext.userAddress;

                return (
                  <div
                    key={submission.creator}
                    className="bg-white rounded-lg shadow-sm p-6"
                  >
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          <span className="text-2xl font-bold text-gray-400">
                            #{index + 1}
                          </span>
                          <h3 className="text-lg font-semibold text-gray-900">
                            {submission.name}
                          </h3>
                          {isOwnSubmission && (
                            <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                              Your Project
                            </span>
                          )}
                        </div>
                        <p className="text-sm text-gray-600 mb-3">
                          By:{" "}
                          <AccountName
                            address={submission.creator as `0x${string}`}
                          />
                        </p>
                        <div className="flex space-x-4">
                          <a
                            href={submission.githubUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-sm text-blue-600 hover:underline"
                          >
                            GitHub →
                          </a>
                          <a
                            href={submission.demoVideoUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-sm text-blue-600 hover:underline"
                          >
                            Demo Video →
                          </a>
                        </div>
                      </div>
                      <div className="flex flex-col items-center ml-6">
                        <div className="text-3xl font-bold text-gray-900 mb-2">
                          {submission.votesReceived}
                        </div>
                        <div className="text-xs text-gray-500 mb-3">votes</div>
                        {isParticipant && !isOwnSubmission && (
                          <div className="flex flex-col space-y-2">
                            {userVotesForThis > 0 ? (
                              <>
                                <span className="text-xs text-center text-gray-600">
                                  Your votes: {userVotesForThis}
                                </span>
                                <button
                                  onClick={() =>
                                    revokeVote.mutate(submission.creator)
                                  }
                                  disabled={revokeVote.isPending}
                                  className="px-3 py-1 text-sm bg-red-100 text-red-700 rounded hover:bg-red-200 disabled:bg-gray-200 transition-colors"
                                >
                                  Remove Vote
                                </button>
                              </>
                            ) : (
                              <button
                                onClick={() => vote.mutate(submission.creator)}
                                disabled={
                                  vote.isPending || votesRemaining === 0
                                }
                                className="px-3 py-1 text-sm bg-green-100 text-green-700 rounded hover:bg-green-200 disabled:bg-gray-200 disabled:text-gray-400 transition-colors"
                              >
                                {votesRemaining === 0
                                  ? "No Votes Left"
                                  : "Vote"}
                              </button>
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </div>
        )}
      </div>
    </div>
  );
}
