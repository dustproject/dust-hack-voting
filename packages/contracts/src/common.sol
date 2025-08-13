// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_SYSTEM, RESOURCE_NAMESPACE } from "@latticexyz/world/src/worldResourceTypes.sol";

bytes14 constant HACKATHON_NAMESPACE = "DUST_HACK_1";
bytes16 constant ROOT_NAME = "";

ResourceId constant HACKATHON_NAMESPACE_ID = ResourceId.wrap(
  bytes32(abi.encodePacked(RESOURCE_NAMESPACE, bytes14(HACKATHON_NAMESPACE), ROOT_NAME))
);
