// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {SupplyChain} from "../src/SupplyChain.sol"; 


contract DeploySupplyChain is Script {

    function run() external returns(SupplyChain){
        vm.startBroadcast(); 
        SupplyChain supplyChain = new SupplyChain(); 
        vm.stopBroadcast(); 
        return supplyChain; 
    }

}