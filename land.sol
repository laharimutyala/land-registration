// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistry {

    struct Land {
        uint id;
        string location;
        address owner;
    }

    mapping(uint256 => Land) public lands;
    mapping(address => mapping(uint256 => bool)) private ownerLands;
    uint256 public landCount;

    constructor() {
        landCount = 0;
    }

    function registerLand(string memory location) public returns (uint256 landId) {
        require(bytes(location).length > 0, "Location cannot be empty");
        landId = landCount + 1;
        lands[landId] = Land(landId, location, msg.sender);
        ownerLands[msg.sender][landId] = true;
        landCount++;
    }

    function transferOwnership(uint256 landId, address newOwner) public {
        require(lands[landId].owner == msg.sender, "You are not the owner of this land");
        require(newOwner != address(0), "Invalid new owner address");

        address oldOwner = lands[landId].owner;
        lands[landId].owner = newOwner;
        ownerLands[oldOwner][landId] = false;
        ownerLands[newOwner][landId] = true;
    }

    function getLandsByOwner(address owner) public view returns (uint256[] memory) {
        uint256[] memory landList = new uint256[](landCount);
        uint256 count = 0;

        for (uint256 i = 1; i <= landCount; i++) {
            if (ownerLands[owner][i]) {
                landList[count] = i;
                count++;
            }
        }

        // Resize the array to the actual number of lands owned
        assembly {
            mstore(landList, count)
        }

        return landList;
    }

    function getLandDetails(uint256 landId) public view returns (uint id, string memory location, address owner) {
        Land memory land = lands[landId];
        return (land.id, land.location, land.owner);
    }
}
