declare const abi: [
  {
    "type": "function",
    "name": "hitForceField",
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
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "hitForceField",
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
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  }
];

export default abi;
