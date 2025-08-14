declare const abi: [
  {
    "type": "function",
    "name": "addFragment",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "forceField",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "refFragmentCoord",
        "type": "uint96",
        "internalType": "Vec3"
      },
      {
        "name": "fragmentCoord",
        "type": "uint96",
        "internalType": "Vec3"
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
    "name": "computeBoundaryFragments",
    "inputs": [
      {
        "name": "forceField",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "fragmentCoord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint96[]",
        "internalType": "Vec3[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "removeFragment",
    "inputs": [
      {
        "name": "caller",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "forceField",
        "type": "bytes32",
        "internalType": "EntityId"
      },
      {
        "name": "fragmentCoord",
        "type": "uint96",
        "internalType": "Vec3"
      },
      {
        "name": "boundaryIdx",
        "type": "uint8[]",
        "internalType": "uint8[]"
      },
      {
        "name": "parents",
        "type": "uint8[]",
        "internalType": "uint8[]"
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
    "name": "validateSpanningTree",
    "inputs": [
      {
        "name": "boundary",
        "type": "uint96[]",
        "internalType": "Vec3[]"
      },
      {
        "name": "boundaryIdx",
        "type": "uint8[]",
        "internalType": "uint8[]"
      },
      {
        "name": "parents",
        "type": "uint8[]",
        "internalType": "uint8[]"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "pure"
  }
];

export default abi;
