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
  address[] public managers; // array of managers
  mapping (address => bool) public isManager; // mapping of managers

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

  // EVENTS
  event ManagerAdd(address indexed owner_, address indexed manager_);
  event ManagerRemove(address indexed owner_, address indexed manager_);
  event OrderSet(address indexed caller_);
  event TrackAdd(address indexed caller_, address indexed trackAddress_, uint256 trackTokenId_, uint256 nftType_);
  event TrackRemove(address indexed caller_, address indexed trackAddress_);

  // MODIFIERS
  modifier onlyOwner() {
    require(msg.sender == IERC721(playlistNftAddress).ownerOf(playlistId), "DegenRadioPlaylist: caller is not the owner");
    _;
  }

  modifier onlyOwnerOrManager() {
    require(
      isManager[msg.sender] || 
      msg.sender == IERC721(playlistNftAddress).ownerOf(playlistId), 
      "OwnableWithManagers: caller is not a manager or owner"
    );
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

  function getManagers() external view returns (address[] memory) {
    return managers;
  }

  function getManagersLength() external view returns (uint256) {
    return managers.length;
  }

  function getTrack(uint256 index_) external view returns (Track memory) {
    return tracks[index_];
  }

  function getTrackOrder() external view returns (uint256[] memory) {
    return customOrder;
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

  // MANAGER
  function removeYourselfAsManager() external {
    require(isManager[msg.sender], "DegenRadioPlaylist: caller is not a manager");

    address manager_ = msg.sender;

    isManager[manager_] = false;
    uint256 length = managers.length;

    for (uint256 i = 0; i < length;) {
      if (managers[i] == manager_) {
        managers[i] = managers[length - 1];
        managers.pop();
        emit ManagerRemove(msg.sender, manager_);
        return;
      }

      unchecked {
        i++;
      }
    }
  }

  // OWNER

  function addManager(address manager_) external onlyOwner {
    require(!isManager[manager_], "OwnableWithManagers: manager already added");
    isManager[manager_] = true;
    managers.push(manager_);
    emit ManagerAdd(msg.sender, manager_);
  }

  function removeManagerByAddress(address manager_) external onlyOwner {
    isManager[manager_] = false;
    uint256 length = managers.length;

    for (uint256 i = 0; i < length;) {
      if (managers[i] == manager_) {
        managers[i] = managers[length - 1];
        managers.pop();
        emit ManagerRemove(msg.sender, manager_);
        return;
      }

      unchecked {
        i++;
      }
    }
  }

  function removeManagerByIndex(uint256 index_) external onlyOwner {
    emit ManagerRemove(msg.sender, managers[index_]);
    isManager[managers[index_]] = false;
    managers[index_] = managers[managers.length - 1];
    managers.pop();
  }

  // MANAGER AND OWNER

  function addTrack(
    address addr_,
    uint256 tokenId_,
    uint256 nftType_
  ) external onlyOwnerOrManager {
    tracks.push(Track(addr_, tokenId_, nftType_));
    emit TrackAdd(msg.sender, addr_, tokenId_, nftType_);
  }

  function addTrackToIndex(
    address addr_,
    uint256 tokenId_,
    uint256 nftType_,
    uint256 index_
  ) external onlyOwnerOrManager {
    tracks[index_] = Track(addr_, tokenId_, nftType_);
    emit TrackAdd(msg.sender, addr_, tokenId_, nftType_);
  }

  function removeTrackByIndex(uint256 index_) external onlyOwnerOrManager {
    require(index_ < tracks.length, "DegenRadioPlaylist: Invalid index");
    require(tracks.length > 1, "DegenRadioPlaylist: Playlist must have at least one track");

    emit TrackRemove(msg.sender, tracks[index_].nftAddress);

    tracks[index_] = tracks[tracks.length - 1];
    tracks.pop();
  }

  function removeTrackByAddress(address addr_) external onlyOwnerOrManager {
    uint256 tracksLength_ = tracks.length;

    for (uint256 i = 0; i < tracksLength_; i++) {
      if (tracks[i].nftAddress == addr_) {
        tracks[i] = tracks[tracksLength_ - 1];
        tracks.pop();
        emit TrackRemove(msg.sender, addr_);
        return;
      }
    }

    revert("DegenRadioPlaylist: Track not found");
  }

  /// @notice Sets the custom order of tracks
  function setCustomOrder(uint256[] memory order_) external onlyOwnerOrManager {
    customOrder = order_;
    emit OrderSet(msg.sender);
  }

}
