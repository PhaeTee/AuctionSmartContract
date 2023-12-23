// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Auctioning {
    address nftAddress;
    address bidToken;
    address public owner;
    address highestBidder;
    uint256 highestBid;
    uint256 public bidEndTime;

    mapping (address => uint256) bids;

    event BidSuccessful (address user, uint256 amount);
    event BidWithdrawn (address user, uint256 amount);
    event AuctionEnded (address winner, uint256 amount);
    

    constructor( address _nftAddress, address _bidToken, uint256 _bidDuration){
        nftAddress = _nftAddress;
        bidToken= _bidToken;
        bidEndTime= block.timestamp + _bidDuration;
        owner= msg.sender;
    }

    function bid (uint256 _amount) external {
        require(block.timestamp <= bidEndTime, "Auction has ended");
        require(_amount > highestBid, "Bid not high enough");

        if (highestBidder != address(0)) {
            IERC721(nftAddress).transferFrom(address(this), highestBidder, highestBid);
        }
        
        IERC20(bidToken).transferFrom(msg.sender, address(this), _amount);

        highestBidder = msg.sender;
        highestBid = _amount;

        bids[msg.sender] += _amount;

        emit BidSuccessful (msg.sender, _amount);
    }


    function withdrawBid(uint256 _amount) external {
        require (msg.sender != highestBidder, "cannot withdraw highest bid");
        uint256 bidAmount = bids[msg.sender];
        require(bidAmount == _amount, "withdraw amount does not match");

        IERC20(bidToken).transfer(msg.sender, _amount);
        bids[msg.sender] = 0;

        emit BidWithdrawn (msg.sender, bidAmount);
    }

    function endAuction(address _highestBidder, uint256 _highestBid) external {
        require(highestBidder != address(0), "no bidder");
        require (msg.sender== owner, "you are not owner");
        require (block.timestamp >= bidEndTime, "Auction has not ended yet");

        IERC721(bidToken).safeTransferFrom(address(this),_highestBidder, _highestBid);
        emit AuctionEnded(highestBidder, highestBid);
    }
}
    

    
    
