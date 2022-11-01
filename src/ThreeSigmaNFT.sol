// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ThreeSigmaNFT is ERC721 {
    uint256 public tokenCounter;

    constructor() ERC721("ThreeSigmaNFT", "TSNFT") {
        tokenCounter = 0;
    }

    function claim(address player) public returns (uint256) {
        uint256 newItemId = tokenCounter;

        _mint(player, newItemId);
        tokenCounter++;

        return newItemId;
    }
}