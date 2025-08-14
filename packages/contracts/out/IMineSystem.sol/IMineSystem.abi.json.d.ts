declare const abi: [
  {
    "type": "function",
    "name": "getRandomOreType",
    "inputs": [
      {
        "name": "coord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "ObjectType"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "mine",
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
        "name": "toolSlot",
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
    "name": "mine",
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
    "name": "mineUntilDestroyed",
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
        "name": "toolSlot",
        "type": "uint16",
        "internalType": "uint16"
      },
      {
        "name": "extraData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "mineUntilDestroyed",
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
        "name": "extraData",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  }
];

export default abi;
