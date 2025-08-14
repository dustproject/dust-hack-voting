declare const abi: [
  {
    "type": "function",
    "name": "energizeMachine",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "machine",
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
    "name": "fuelMachine",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "machine",
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
