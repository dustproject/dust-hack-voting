import { useState } from "react";
import { useParams, Link } from "react-router-dom";
import { AccountName } from "../common/AccountName";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { resourceToHex } from "@latticexyz/common";
import mudConfig from "contracts/mud.config";
import VotingSystemAbi from "contracts/out/VotingSystem.sol/VotingSystem.abi.json";
import { useDustClient } from "../common/useDustClient";

interface Submission {
  creator: string;
  name: string;
  githubUrl: string;
  demoVideoUrl: string;
  votesReceived: number;
  submittedTimestamp: number;
}

interface ProjectDetailsProps {
  submissions: Submission[];
  userAddress?: string;
  isParticipant?: boolean;
  votesRemaining?: number;
  getUserVotesForSubmission: (creator: string) => number;
  onVote?: (creator: string) => void;
  onRevokeVote?: (creator: string) => void;
  isPending?: boolean;
  readOnly?: boolean;
}

export function ProjectDetails({
  submissions,
  userAddress,
  isParticipant = false,
  votesRemaining = 0,
  getUserVotesForSubmission,
  onVote,
  onRevokeVote,
  isPending = false,
  readOnly = false,
}: ProjectDetailsProps) {
  const { data: dustClient } = useDustClient();
  const { creator } = useParams<{ creator: string }>();
  const queryClient = useQueryClient();
  const [isEditing, setIsEditing] = useState(false);
  const [editForm, setEditForm] = useState({
    name: "",
    githubUrl: "",
    demoVideoUrl: "",
  });

  const submission = submissions.find((s) => s.creator === creator);

  // Update mutations
  const updateName = useMutation({
    mutationFn: async (name: string) => {
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
            functionName: "updateName",
            args: [name],
          },
        ],
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries();
      setIsEditing(false);
    },
  });

  const updateGithubUrl = useMutation({
    mutationFn: async (githubUrl: string) => {
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
            functionName: "updateGithubUrl",
            args: [githubUrl],
          },
        ],
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries();
    },
  });

  const updateDemoVideoUrl = useMutation({
    mutationFn: async (demoVideoUrl: string) => {
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
            functionName: "updateDemoVideoUrl",
            args: [demoVideoUrl],
          },
        ],
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries();
    },
  });

  const handleEdit = () => {
    if (submission) {
      setEditForm({
        name: submission.name,
        githubUrl: submission.githubUrl,
        demoVideoUrl: submission.demoVideoUrl,
      });
      setIsEditing(true);
    }
  };

  const handleSave = async () => {
    const updates = [];
    if (editForm.name !== submission?.name) {
      updates.push(updateName.mutateAsync(editForm.name));
    }
    if (editForm.githubUrl !== submission?.githubUrl) {
      updates.push(updateGithubUrl.mutateAsync(editForm.githubUrl));
    }
    if (editForm.demoVideoUrl !== submission?.demoVideoUrl) {
      updates.push(updateDemoVideoUrl.mutateAsync(editForm.demoVideoUrl));
    }

    if (updates.length > 0) {
      await Promise.all(updates);
    }
    setIsEditing(false);
  };

  if (!submission) {
    return (
      <div className="max-w-4xl mx-auto p-6">
        <div className="bg-white rounded-lg shadow-sm p-8 text-center">
          <p className="text-gray-500 mb-4">Project not found</p>
          <Link to="/" className="text-blue-600 hover:underline">
            ← Back to projects
          </Link>
        </div>
      </div>
    );
  }

  const userVotesForThis = getUserVotesForSubmission(submission.creator);
  const isOwnSubmission = submission.creator === userAddress;

  // Extract video ID from YouTube URL
  const getYouTubeVideoId = (url: string) => {
    const match = url.match(
      /(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=))([\w-]{11})/
    );
    return match ? match[1] : null;
  };

  const videoId = getYouTubeVideoId(submission.demoVideoUrl);

  return (
    <div className="max-w-4xl mx-auto p-6">
      <Link to="/" className="inline-block mb-6 text-blue-600 hover:underline">
        ← Back to all projects
      </Link>

      <div className="bg-white rounded-lg shadow-sm p-8">
        {isEditing ? (
          <div className="space-y-4">
            <h1 className="text-2xl font-bold text-gray-900 mb-6">
              Edit Project
            </h1>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Project Name
              </label>
              <input
                type="text"
                value={editForm.name}
                onChange={(e) =>
                  setEditForm({ ...editForm, name: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                GitHub Repository URL
              </label>
              <input
                type="url"
                value={editForm.githubUrl}
                onChange={(e) =>
                  setEditForm({ ...editForm, githubUrl: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Demo Video URL
              </label>
              <input
                type="url"
                value={editForm.demoVideoUrl}
                onChange={(e) =>
                  setEditForm({ ...editForm, demoVideoUrl: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-gray-900"
              />
            </div>
            <div className="flex space-x-3">
              <button
                onClick={handleSave}
                disabled={
                  updateName.isPending ||
                  updateGithubUrl.isPending ||
                  updateDemoVideoUrl.isPending
                }
                className="px-4 py-2 bg-gray-900 text-white rounded-lg hover:bg-gray-800 disabled:bg-gray-400"
              >
                Save Changes
              </button>
              <button
                onClick={() => setIsEditing(false)}
                className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300"
              >
                Cancel
              </button>
            </div>
          </div>
        ) : (
          <>
            <div className="flex items-start justify-between mb-6">
              <div>
                <h1 className="text-3xl font-bold text-gray-900 mb-2">
                  {submission.name}
                </h1>
                <p className="text-gray-600">
                  By:{" "}
                  <AccountName address={submission.creator as `0x${string}`} />
                </p>
              </div>
              <div className="text-right">
                <div className="text-4xl font-bold text-gray-900">
                  {submission.votesReceived}
                </div>
                <div className="text-sm text-gray-500">votes</div>
              </div>
            </div>

            {isOwnSubmission && !readOnly && (
              <div className="mb-6">
                <button
                  onClick={handleEdit}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  Edit Project Details
                </button>
              </div>
            )}

            <div className="flex space-x-6 mb-8">
              <a
                href={submission.githubUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:underline"
              >
                GitHub →
              </a>
              <a
                href={submission.demoVideoUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="text-blue-600 hover:underline"
              >
                Demo Video →
              </a>
            </div>

            {videoId && (
              <div className="mb-8">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">
                  Demo Video
                </h2>
                <div
                  className="relative w-full"
                  style={{ paddingBottom: "56.25%" }}
                >
                  <iframe
                    className="absolute top-0 left-0 w-full h-full rounded-lg border-0"
                    src={`https://www.youtube.com/embed/${videoId}`}
                    title="Demo Video"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowFullScreen
                  />
                </div>
              </div>
            )}

            {!readOnly &&
              isParticipant &&
              !isOwnSubmission &&
              onVote &&
              onRevokeVote && (
                <div className="border-t pt-6">
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">
                    Your Vote
                  </h3>
                  {userVotesForThis > 0 ? (
                    <div className="flex items-center space-x-4">
                      <span className="text-gray-600">
                        You've given {userVotesForThis} vote
                        {userVotesForThis > 1 ? "s" : ""} to this project
                      </span>
                      <button
                        onClick={() => onRevokeVote(submission.creator)}
                        disabled={isPending}
                        className="px-4 py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 disabled:bg-gray-200"
                      >
                        Remove Vote
                      </button>
                    </div>
                  ) : (
                    <button
                      onClick={() => onVote(submission.creator)}
                      disabled={isPending || votesRemaining === 0}
                      className="px-4 py-2 bg-green-100 text-green-700 rounded-lg hover:bg-green-200 disabled:bg-gray-200 disabled:text-gray-400"
                    >
                      {votesRemaining === 0
                        ? "No Votes Left"
                        : `Vote for this project (${votesRemaining} remaining)`}
                    </button>
                  )}
                </div>
              )}
          </>
        )}
      </div>
    </div>
  );
}
