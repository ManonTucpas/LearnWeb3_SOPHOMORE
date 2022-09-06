
//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Whitelist {

    // Max number of whitlist addresses allowed
    uint8 public maxWhitelistedAddresses;

    // If an address is whitelised, we'd set it to true, otherwise will be set to false by default
    mapping(address => bool) public whitelistedAddresses;

    // Keep track of how many addresses have been whitelisted
    uint8 public numAddressesWhitelisted;

    // In the constructor we'll set the max number addresses whitelisted
    // Value we'll be put by the user at the time of deployment
    constructor(uint8 _maxWhitelistedAddresses) {
        maxWhitelistedAddresses = _maxWhitelistedAddresses;
    }

    /**
        addAddressToWhitelist : add the sender's address to the whitelist
     */
    function addAddressToWhitelist() public {
        
        // Check if the address is not already in the whitelist
        require(!whitelistedAddresses[msg.sender], "Sender has already been whitelisted");

        // Check if the max number of whitelisted adresses is reached
        require(numAddressesWhitelisted < maxWhitelistedAddresses, "More addresses can't be added, limit reached");

        // Set to true the address in the mapping
        whitelistedAddresses[msg.sender] = true;

        // Increment the number of whitelisted addresses
        numAddressesWhitelisted += 1;
    }
}