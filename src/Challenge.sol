// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Challenge is IERC721Receiver {
    // Last address that made a play.
    address public lastAddressEther;
    address public lastAddressNFT;
    // Time at last play.
    uint256 internal timeAtLastPlayEther;
    uint256 internal timeAtLastPlayNFT;
    // List of all nftIDs.
    uint256[] internal nftIDs;
    // ThreeSigmaNFT Interface
    IERC721 ThreeSigmaNFT;

    // Initialize NFT Interface with it's SC address
    constructor(address nftAdress) {
        ThreeSigmaNFT = IERC721(nftAdress);
    }

    // Make a play - registers your account and the time of the play. 
    // Can't make a play if a day has gone through since the last play.
    // You are the winner if the lastAdress was your's and vice-versa.
    function playForEther() public payable {
        require(!checkTime(timeAtLastPlayEther), "A day has gone through, you can't play anymore. Sorry!");

        lastAddressEther = msg.sender;
        timeAtLastPlayEther = block.timestamp;
    }

    // Same as funtion above but for the NFT game.
    function playForNFTs(uint256 nftID) external {
        require(ThreeSigmaNFT.ownerOf(nftID) == msg.sender, "That's not your token!");
        require(!checkTime(timeAtLastPlayNFT), "A day has gone through, you can't play anymore. Sorry!");

        ThreeSigmaNFT.transferFrom(msg.sender, address(this), nftID);

        nftIDs.push(nftID);
        lastAddressNFT = msg.sender;
        timeAtLastPlayNFT = block.timestamp;
    }

    // Claims reward. Can't claim the reward if a day hasn't gone through since
    // the last play or you were not the last player.
    function claimEther() public payable {
        require(checkTime(timeAtLastPlayEther), "A day hasn't gone through since the last play!");
        require(lastAddressEther == msg.sender, "Unfortunately you are not the winner. Sorry!");

        (bool rewardSent,) = payable(msg.sender).call{value: address(this).balance}
                             ("Congratulations, you are the winner!");
        require(rewardSent, "Could not send reward...");

        timeAtLastPlayEther = 0;
    }

    // 
    function claimNFTs() public {
        require(checkTime(timeAtLastPlayNFT), "A day hasn't gone through since the last play!");
        require(lastAddressNFT == msg.sender, "Unfortunately you are not the winner. Sorry!");
        
        for(uint256 i = 0; i < nftIDs.length; i++) {
            ThreeSigmaNFT.safeTransferFrom(address(this), msg.sender, nftIDs[i]);
        }
        
        timeAtLastPlayNFT = 0;
    }

    // Checks if it has been over a day since the last play.
    function checkTime(uint256 timeAtLastPlay) internal view returns(bool) {
        return timeAtLastPlay == 0 ? false : block.timestamp - timeAtLastPlay >= 30;
    }

    // Function called by safeTransfer from.
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        nftIDs.push(tokenId);
        lastAddressNFT = from;
        return IERC721Receiver.onERC721Received.selector;
    }
}