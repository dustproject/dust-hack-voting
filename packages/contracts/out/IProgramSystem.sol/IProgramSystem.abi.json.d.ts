declare const abi: [
  {
    "type": "function",
    "name": "attachProgram",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "target",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "program",
        "type": "bytes32",
        "internalType": "ProgramId"
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
    "name": "detachProgram",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "target",
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
    "name": "updateProgram",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "target",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "newProgram",
        "type": "bytes32",
        "internalType": "ProgramId"
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
    "name": "updateProgram",
    "inputs": [
      {
        "name": "target",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "newProgram",
        "type": "bytes32",
        "internalType": "ProgramId"
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
