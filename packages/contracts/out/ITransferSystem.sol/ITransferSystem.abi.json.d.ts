declare const abi: [
  {
    "type": "function",
    "name": "transfer",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "from",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "to",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "transfers",
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
    "name": "transferAmounts",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "from",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "to",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "amounts",
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
