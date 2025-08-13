import { defineWorld } from "@latticexyz/world";

export default defineWorld({
  codegen: {
    generateSystemLibraries: true,
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
  namespace: "DUST_HACK_1",
  systems: {
    ForceFieldProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false },
    },
    SpawnTileProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false },
    },
    ChestProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false },
    },
    BedProgram: {
      openAccess: false,
      deploy: { registerWorldFunctions: false },
    },
    ChestPrizeProgram: {
      openAccess: false,
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
  },
});
