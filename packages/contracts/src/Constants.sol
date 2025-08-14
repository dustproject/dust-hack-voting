// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { IWorld } from "@dust/world/src/codegen/world/IWorld.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_NAMESPACE } from "@latticexyz/world/src/worldResourceTypes.sol";

library Constants {
  address internal constant DUST_ADDRESS = 0x253eb85B3C953bFE3827CC14a151262482E7189C;
  IWorld internal constant DUST_WORLD = IWorld(DUST_ADDRESS);
  ResourceId constant NAMESPACE_ID =
    ResourceId.wrap(bytes32(abi.encodePacked(RESOURCE_NAMESPACE, bytes14("dev_hack_1"), "")));
}
