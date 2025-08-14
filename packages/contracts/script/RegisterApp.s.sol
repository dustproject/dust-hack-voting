// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { metadataSystem } from "@latticexyz/world-module-metadata/src/codegen/experimental/systems/MetadataSystemLib.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { Constants } from "../src/Constants.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { console } from "forge-std/console.sol";

import { Script } from "./Script.sol";

contract RegisterApp is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    startBroadcast();

    string memory appUrl = "https://dust-hack-voting.vercel.app/dust-app.json";
    console.log("Registering app with url: %s", appUrl);

    metadataSystem.setResourceTag(Constants.NAMESPACE_ID, "dust.appConfigUrl", bytes(appUrl));

    vm.stopBroadcast();
  }
}
