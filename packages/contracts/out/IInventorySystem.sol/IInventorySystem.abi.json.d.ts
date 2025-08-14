declare const abi: [
  {
    "type": "function",
    "name": "drop",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "slots",
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
      },
      {
        "name": "coord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "pickup",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "slotTransfers",
        "type": "tuple[]",
        "internalType": "struct SlotTransfer[]",
        "components": [
          {
            "name": "slotFrom",
            "type": "uint16",
            "internalType": "uint16"
          },
          {
            "name": "slotTo",
            "type": "uint16",
            "internalType": "uint16"
          },
          {
            "name": "amount",
            "type": "uint16",
            "internalType": "uint16"
          }
        ]
      },
      {
        "name": "coord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "pickupAll",
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
