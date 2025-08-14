declare const abi: [
  {
    "type": "function",
    "name": "buildAndAttachProgram",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "coord",
        "type": "uint96",
        "internalType": "Vec3"
      },
      {
        "name": "slot",
        "type": "uint16",
        "internalType": "uint16"
      },
      {
        "name": "program",
        "type": "bytes32",
        "internalType": "ProgramId"
      },
      {
        "name": "buildExtraData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "attachExtraData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "EntityId"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "buildAndAttachProgramWithOrientation",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "coord",
        "type": "uint96",
        "internalType": "Vec3"
      },
      {
        "name": "slot",
        "type": "uint16",
        "internalType": "uint16"
      },
      {
        "name": "orientation",
        "type": "uint8",
        "internalType": "Orientation"
      },
      {
        "name": "program",
        "type": "bytes32",
        "internalType": "ProgramId"
      },
      {
        "name": "buildExtraData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "attachExtraData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "EntityId"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "jumpBuildAndAttachProgram",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "slot",
        "type": "uint16",
        "internalType": "uint16"
      },
      {
        "name": "program",
        "type": "bytes32",
        "internalType": "ProgramId"
      },
      {
        "name": "buildExtraData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "attachExtraData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "EntityId"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "jumpBuildWithOrientationAndAttachProgram",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "slot",
        "type": "uint16",
        "internalType": "uint16"
      },
      {
        "name": "orientation",
        "type": "uint8",
        "internalType": "Orientation"
      },
      {
        "name": "program",
        "type": "bytes32",
        "internalType": "ProgramId"
      },
      {
        "name": "buildExtraData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "attachExtraData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "EntityId"
      }
    ],
    "stateMutability": "nonpayable"
  }
];

export default abi;
