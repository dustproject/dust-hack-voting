import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  codegen: {
    generateSystemLibraries: true,
  },
  enums: {
    LeaderboardPosition: ["Unset", "First", "Second", "Third"],
  },
  userTypes: {
    ObjectType: {
      filePath: "@dust/world/src/types/ObjectType.sol",
      type: "uint16",
    },
    EntityId: {
      filePath: "@dust/world/src/types/EntityId.sol",
      type: "bytes32",
    },
    ProgramId: {
      filePath: "@dust/world/src/types/ProgramId.sol",
      type: "bytes32",
    },
    ResourceId: {
      filePath: "@latticexyz/store/src/ResourceId.sol",
      type: "bytes32",
    },
  },
  // Replace this with a unique namespace
  namespace: "dev_hack_1",
  systems: {
    ForceFieldProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false, disabled: true },
    },
    SpawnTileProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false, disabled: true },
    },
    ChestProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false, disabled: true },
    },
    BedProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false, disabled: true },
    },
    ChestPrizeProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false },
    },
    ChestPrizeSystem: {
      deploy: { registerWorldFunctions: false },
    },
    VotingSystem: {
      deploy: { registerWorldFunctions: false },
    },
  },
  tables: {
    Config: {
      schema: {
        votingStartTimestamp: "uint32",
        votingEndTimestamp: "uint32",
        votesPerParticipant: "uint32",
      },
      key: [],
    },
    Moderators: {
      schema: {
        user: "address",
        isModerator: "bool",
      },
      key: ["user"],
    },
    Submissions: {
      schema: {
        creator: "address",
        submittedTimestamp: "uint32",
        votesReceived: "uint32",
        name: "string",
        githubUrl: "string",
        demoVideoUrl: "string",
      },
      key: ["creator"],
    },
    Participants: {
      schema: {
        user: "address",
        isParticipant: "bool",
        votesGiven: "uint32",
      },
      key: ["user"],
    },
    Votes: {
      schema: {
        voter: "address",
        submission: "address",
        votesGiven: "uint32",
      },
      key: ["voter", "submission"],
    },
    VoteHistory: {
      schema: {
        submission: "address",
        timestamp: "uint32",
        voter: "address",
        diff: "int32",
        totalVotes: "uint32",
      },
      key: ["submission", "voter", "timestamp"],
      type: "offchainTable",
    },
    SubmissionCreators: {
      schema: {
        creators: "address[]",
      },
      key: [],
    },
    ChestPrizeConfig: {
      schema: {
        chest: "EntityId",
        position: "LeaderboardPosition",
      },
      key: ["chest"],
    },
  },
});
