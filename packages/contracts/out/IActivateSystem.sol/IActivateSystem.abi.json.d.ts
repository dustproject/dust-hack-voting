declare const abi: [
  {
    "type": "function",
    "name": "activate",
    "inputs": [
      {
        "name": "entityId",
        "type": "bytes32",
        "internalType": "EntityId"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "activatePlayer",
    "inputs": [
      {
        "name": "playerAddress",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  }
];

export default abi;
