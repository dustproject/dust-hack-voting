declare const abi: [
  {
    "type": "function",
    "name": "removeDeadPlayerFromBed",
    "inputs": [
      {
        "name": "player",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "dropCoord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "sleep",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "bed",
        "type": "bytes32",
        "internalType": "EntityId"
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
    "name": "wakeup",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "spawnCoord",
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
