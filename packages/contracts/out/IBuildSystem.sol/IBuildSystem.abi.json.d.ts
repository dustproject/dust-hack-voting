declare const abi: [
  {
    "type": "function",
    "name": "build",
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
        "name": "extraData",
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
    "name": "buildWithOrientation",
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
        "name": "extraData",
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
    "name": "jumpBuild",
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
        "name": "extraData",
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
    "name": "jumpBuildWithOrientation",
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
        "name": "extraData",
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
