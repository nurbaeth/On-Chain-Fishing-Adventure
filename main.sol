// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract OnChainFishing is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Fish {
        string species;
        uint256 rarity;
    }

    mapping(uint256 => Fish) public fishData;
    mapping(address => uint256) public lastCast;

    event FishCaught(address indexed player, uint256 tokenId, string species, uint256 rarity);

    constructor() ERC721("OnChainFishing", "FISH") {}

    function castLine() public {
        require(block.timestamp > lastCast[msg.sender] + 1 minutes, "Wait before fishing again");
        lastCast[msg.sender] = block.timestamp;

        _tokenIds.increment();
        uint256 newFishId = _tokenIds.current();

        Fish memory newFish = _generateRandomFish(newFishId);
        fishData[newFishId] = newFish;

        _mint(msg.sender, newFishId);
        emit FishCaught(msg.sender, newFishId, newFish.species, newFish.rarity);
    }

    function _generateRandomFish(uint256 tokenId) internal view returns (Fish memory) {
        string[3] memory species = ["Salmon", "Tuna", "Shark"];
        uint256 rarity = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, tokenId))) % 100;
        string memory chosenSpecies = species[rarity % species.length];

        return Fish(chosenSpecies, rarity);
    }
}
