// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ERC721MeritocraticVotesUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract DeployAndTest is Script {
    ERC721MeritocraticVotesUpgradeable public meritocraticVotes;
    ERC1967Proxy public proxy;

    function run() external {
        address deployer = msg.sender;

        vm.startBroadcast();

        // Deploy the logic contract
        meritocraticVotes = new ERC721MeritocraticVotesUpgradeable();

        // Deploy the proxy and point it to the logic contract
        proxy = new ERC1967Proxy(
            address(meritocraticVotes),
            abi.encodeWithSelector(
                meritocraticVotes.initialize.selector,
                "My Token",                 // Token name
                "MTK",                      // Token symbol
                deployer,                   // Attestation Station address (for now, we can use deployer)
                0.2 ether                   // Base voting power
            )
        );

        // Cast the proxy address to the interface of your contract
        ERC721MeritocraticVotesUpgradeable proxyAsMeritocraticVotes = ERC721MeritocraticVotesUpgradeable(address(proxy));

        // Test setting a multiplier (can be done by the contract owner, which is the deployer)
        proxyAsMeritocraticVotes.setMultiplier(1, "isBuilder", 2000); // 20% multiplier for tokenId 1

        vm.stopBroadcast();
    }
}
