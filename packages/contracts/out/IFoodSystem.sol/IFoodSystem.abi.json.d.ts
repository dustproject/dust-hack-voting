declare const abi: [
  {
    "type": "function",
    "name": "eat",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "slotAmount",
        "type": "tuple",
        "internalType": "struct SlotAmount",
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
