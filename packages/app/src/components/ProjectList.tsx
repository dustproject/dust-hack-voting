import { Link } from "react-router-dom";
import { AccountName } from "../common/AccountName";

interface Submission {
  creator: string;
  name: string;
  githubUrl: string;
  demoVideoUrl: string;
  votesReceived: number;
  submittedTimestamp: number;
}

interface ProjectListProps {
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

export function ProjectList({
  submissions,
  userAddress,
  isParticipant = false,
  votesRemaining = 0,
  getUserVotesForSubmission,
  onVote,
  onRevokeVote,
  isPending = false,
  readOnly = false,
}: ProjectListProps) {
  if (submissions.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow-sm p-8 text-center text-gray-500">
        No projects submitted yet
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {submissions.map((submission, index) => {
        const userVotesForThis = getUserVotesForSubmission(submission.creator);
        const isOwnSubmission = submission.creator === userAddress;

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
                  <Link
                    to={`/project/${submission.creator}`}
                    className="text-lg font-semibold text-gray-900 hover:text-blue-600 transition-colors"
                  >
                    {submission.name}
                  </Link>
                  {isOwnSubmission && !readOnly && (
                    <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                      Your Project
                    </span>
                  )}
                </div>
                <p className="text-sm text-gray-600 mb-3">
                  By:{" "}
                  <AccountName address={submission.creator as `0x${string}`} />
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
                  <Link
                    to={`/project/${submission.creator}`}
                    className="text-sm text-purple-600 hover:underline"
                  >
                    View Details →
                  </Link>
                </div>
              </div>
              <div className="flex flex-col items-center ml-6">
                <div className="text-3xl font-bold text-gray-900 mb-2">
                  {submission.votesReceived}
                </div>
                <div className="text-xs text-gray-500 mb-3">votes</div>
                {!readOnly &&
                  isParticipant &&
                  !isOwnSubmission &&
                  onVote &&
                  onRevokeVote && (
                    <div className="flex flex-col space-y-2">
                      {userVotesForThis > 0 ? (
                        <>
                          <span className="text-xs text-center text-gray-600">
                            Your votes: {userVotesForThis}
                          </span>
                          <button
                            onClick={() => onRevokeVote(submission.creator)}
                            disabled={isPending}
                            className="px-3 py-1 text-sm bg-red-100 text-red-700 rounded hover:bg-red-200 disabled:bg-gray-200 transition-colors"
                          >
                            Remove Vote
                          </button>
                        </>
                      ) : (
                        <button
                          onClick={() => onVote(submission.creator)}
                          disabled={isPending || votesRemaining === 0}
                          className="px-3 py-1 text-sm bg-green-100 text-green-700 rounded hover:bg-green-200 disabled:bg-gray-200 disabled:text-gray-400 transition-colors"
                        >
                          {votesRemaining === 0 ? "No Votes Left" : "Vote"}
                        </button>
                      )}
                    </div>
                  )}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
