declare const abi: [
  {
    "type": "function",
    "name": "move",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "newCoords",
        "type": "uint96[]",
        "internalType": "Vec3[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "moveDirections",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "directions",
        "type": "uint8[]",
        "internalType": "enum Direction[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "moveDirectionsPacked",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "packed",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  }
];

export default abi;
