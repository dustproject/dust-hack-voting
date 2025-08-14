declare const abi: [
  {
    "type": "function",
    "name": "debugAddToInventory",
    "inputs": [
      {
        "name": "owner",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "objectType",
        "type": "uint16",
        "internalType": "ObjectType"
      },
      {
        "name": "numObjectsToAdd",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "debugAddToolToInventory",
    "inputs": [
      {
        "name": "owner",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "toolObjectType",
        "type": "uint16",
        "internalType": "ObjectType"
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
    "name": "debugRemoveFromInventory",
    "inputs": [
      {
        "name": "owner",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "objectType",
        "type": "uint16",
        "internalType": "ObjectType"
      },
      {
        "name": "numObjectsToRemove",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "debugRemoveToolFromInventory",
    "inputs": [
      {
        "name": "owner",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "tool",
        "type": "bytes32",
        "internalType": "EntityId"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "debugTeleportPlayer",
    "inputs": [
      {
        "name": "playerAddress",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "finalCoord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  }
];

export default abi;
