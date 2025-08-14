declare const abi: [
  {
    "type": "function",
    "name": "exploreChunk",
    "inputs": [
      {
        "name": "chunkCoord",
        "type": "uint96",
        "internalType": "Vec3"
      },
      {
        "name": "chunkData",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "merkleProof",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "exploreRegionEnergy",
    "inputs": [
      {
        "name": "regionCoord",
        "type": "uint96",
        "internalType": "Vec3"
      },
      {
        "name": "vegetationCount",
        "type": "uint32",
        "internalType": "uint32"
      },
      {
        "name": "merkleProof",
        "type": "bytes32[]",
        "internalType": "bytes32[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getObjectTypeAt",
    "inputs": [
      {
        "name": "coord",
        "type": "uint96",
        "internalType": "Vec3"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "ObjectType"
      }
    ],
    "stateMutability": "view"
  }
];

export default abi;
