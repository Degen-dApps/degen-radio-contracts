// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

interface IERC721 {
  function ownerOf(uint256 tokenId) external view returns (address);
}

/**
 * @title Degen Radio Playlist
 * @author Tempe Techie
 * @notice Smart contract that holds an array of selected music NFTs.
 * @notice Put the radio on the blockchain.
 */
contract DegenRadioPlaylist {

  struct Track {
    address nftAddress;
    uint256 tokenId;
    uint256 nftType; // see below, default is 0
  }

  // NFT TYPES
  // 0 - ERC-721 where each NFT has the same metadata (token ID does not matter)
  // 1 - ERC-721 where each NFT has different metadata
  // 2 - ERC-1155

  address public immutable playlistNftAddress; // playlist ownership NFT contract address (DegenRadioPlaylistNft.sol)
  uint256 public immutable playlistId; // playlist ownership NFT token ID

  Track[] public tracks; // array of Music NFT contract addresses
  uint256[] public customOrder; // array of custom order of tracks indices (if it's not set, the default is 0, 1, 2, ...)

  // MODIFIERS
  modifier onlyOwner() {
    require(msg.sender == IERC721(playlistNftAddress).ownerOf(playlistId), "DegenRadioPlaylist: caller is not the owner");
    _;
  }

  // CONSTRUCTOR
  constructor(
    uint256 playlistId_,
    address playlistNftAddr_, 
    address trackAddr_, // the first track in the playlist (playlist must have at least one track)
    uint256 trackTokenId_,
    uint256 trackType_
  ) {
    playlistId = playlistId_;
    playlistNftAddress = playlistNftAddr_;
    tracks.push(Track(trackAddr_, trackTokenId_, trackType_)); 
  }

  // READ

  function getLastTracks(uint256 amount_) external view returns (Track[] memory) {
    uint256 tracksLength_ = tracks.length;

    if (amount_ >= tracksLength_) {
      return tracks;
    }

    Track[] memory lastTracks_ = new Track[](amount_);

    for (uint256 i = 0; i < amount_; i++) {
      lastTracks_[i] = tracks[tracksLength_ - amount_ + i];
    }

    return lastTracks_;
  }

  function getTrack(uint256 index_) external view returns (Track memory) {
    return tracks[index_];
  }

  function getTrackData(uint256 index_) external view returns (address nftAddress, uint256 tokenId, uint256 nftType) {
    Track memory track_ = tracks[index_];
    return (track_.nftAddress, track_.tokenId, track_.nftType);
  }

  function getTracks(uint256 startIndex_, uint256 endIndex_) external view returns (Track[] memory) {
    require(startIndex_ <= endIndex_, "DegenRadioPlaylist: invalid range");

    uint256 tracksLength_ = tracks.length;

    if (endIndex_ >= tracksLength_) {
      endIndex_ = tracksLength_ - 1;
    }

    uint256 range_ = endIndex_ - startIndex_ + 1;
    Track[] memory selectedTracks_ = new Track[](range_);

    for (uint256 i = 0; i < range_; i++) {
      selectedTracks_[i] = tracks[startIndex_ + i];
    }

    return selectedTracks_;
  }

  function getTracksLength() external view returns (uint256) {
    return tracks.length;
  }

  // OWNER

  function addTrack(
    address addr_,
    uint256 tokenId_,
    uint256 nftType_
  ) external onlyOwner {
    tracks.push(Track(addr_, tokenId_, nftType_));
  }

  function addTrackToIndex(
    address addr_,
    uint256 tokenId_,
    uint256 nftType_,
    uint256 index_
  ) external onlyOwner {
    tracks[index_] = Track(addr_, tokenId_, nftType_);
  }

  function removeTrackByIndex(uint256 index_) external onlyOwner {
    require(index_ < tracks.length, "DegenRadioPlaylist: Invalid index");
    require(tracks.length > 1, "DegenRadioPlaylist: Playlist must have at least one track");

    tracks[index_] = tracks[tracks.length - 1];

    tracks.pop();
  }

  function removeTrackByAddress(address addr_) external onlyOwner {
    uint256 tracksLength_ = tracks.length;

    for (uint256 i = 0; i < tracksLength_; i++) {
      if (tracks[i].nftAddress == addr_) {
        tracks[i] = tracks[tracksLength_ - 1];
        tracks.pop();
        return;
      }
    }

    revert("DegenRadioPlaylist: Track not found");
  }

  /// @notice Sets the custom order of tracks
  function setCustomOrder(uint256[] memory order_) external onlyOwner {
    customOrder = order_;
  }

}
