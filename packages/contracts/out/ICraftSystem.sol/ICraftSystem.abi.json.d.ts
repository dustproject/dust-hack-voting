declare const abi: [
  {
    "type": "function",
    "name": "craft",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "recipeId",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "inputs",
        "type": "tuple[]",
        "internalType": "struct SlotAmount[]",
        "components": [
          {
            "name": "slot",
            "type": "uint16",
            "internalType": "uint16"
          },
          {
            "name": "amount",
            "type": "uint16",
            "internalType": "uint16"
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "craftWithStation",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "station",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "recipeId",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "inputs",
        "type": "tuple[]",
        "internalType": "struct SlotAmount[]",
        "components": [
          {
            "name": "slot",
            "type": "uint16",
            "internalType": "uint16"
          },
          {
            "name": "amount",
            "type": "uint16",
            "internalType": "uint16"
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  }
];

export default abi;
