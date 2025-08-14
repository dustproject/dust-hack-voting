declare const abi: [
  {
    "type": "function",
    "name": "getRandomSpawnChunk",
    "inputs": [
      {
        "name": "blockNumber",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "sender",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "chunk",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getRandomSpawnCoord",
    "inputs": [
      {
        "name": "blockNumber",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "sender",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "spawnCoord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isValidSpawn",
    "inputs": [
      {
        "name": "spawnCoord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "randomSpawn",
    "inputs": [
      {
        "name": "blockNumber",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "spawnCoord",
        "type": "uint96",
        "internalType": "Vec3"
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
    "name": "spawn",
    "inputs": [
      {
        "name": "spawnTile",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "spawnCoord",
        "type": "uint96",
        "internalType": "Vec3"
      },
      {
        "name": "spawnEnergy",
        "type": "uint128",
        "internalType": "uint128"
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
