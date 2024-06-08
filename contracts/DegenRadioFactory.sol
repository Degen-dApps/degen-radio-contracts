// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { DegenRadioPlaylist } from "./DegenRadioPlaylist.sol";

interface IDegenRadioPlaylistNft {
  function addPlaylist(
    address playlistAddress_,
    address playlistOwner_,
    string memory name_,
    string memory description_,
    string memory image_
  ) external;

  function getCounter() external view returns (uint256);
}

/**
 * @title Degen Radio Playlist Factory
 * @author Tempe Techie
 * @notice Smart contract through which Degen Radio Playlists are created.
 * @notice Put the radio on the blockchain.
 */
contract DegenRadioFactory {
  address public immutable playlistNftAddress; // address of the playlist NFT contract (DegenRadioPlaylistNft.sol)
  address public owner; // owner of the factory
  uint256 public price = 0; // price to create a playlist

  // CONSTRUCTOR
  constructor(address playlistNftAddress_) {
    owner = msg.sender;
    playlistNftAddress = playlistNftAddress_;
  }

  // MODIFIERS
  modifier onlyOwner() {
    require(msg.sender == owner, "DegenRadioFactory: caller is not the owner");
    _;
  }

  // EVENTS
  event OwnerSet(address indexed caller_, address indexed owner_);
  event PlaylistCreated(address indexed caller_, address indexed playlistAddress_, uint256 paid_);
  event PriceSet(address indexed caller_, uint256 price_);

  // WRITE
  /**
   * @notice Creates a new Degen Radio Playlist
   * @param name_ Name of the playlist
   * @param description_ Description of the playlist
   * @param image_ Image of the playlist
   * @param trackAddress_ Address of the first track
   * @return playlistAddress_ Address of the new playlist
   */
  function createPlaylist(
    string memory name_,
    string memory description_,
    string memory image_,
    address trackAddress_, // track NFT contract address
    uint256 trackTokenId_, // track NFT token ID
    uint256 trackType_, // track NFT type (see types in DegenRadioPlaylist.sol)
    uint256 trackChainId_ // chain ID of the track NFT contract
  ) external payable returns (address playlistAddress_) {
    require(msg.value >= price, "DegenRadioFactory: insufficient funds");

    // send payment to owner
    if (msg.value > 0 && owner != address(0)) {
      (bool success, ) = owner.call{value: address(this).balance}("");
      require(success, "DegenRadioFactory: payment failed");
    }

    uint256 counter_ = IDegenRadioPlaylistNft(playlistNftAddress).getCounter();

    playlistAddress_ = address(new DegenRadioPlaylist(
      counter_, // playlist ID
      playlistNftAddress,
      trackAddress_,
      trackTokenId_,
      trackType_,
      trackChainId_
    ));

    IDegenRadioPlaylistNft(playlistNftAddress).addPlaylist(
      playlistAddress_,
      msg.sender,
      name_,
      description_,
      image_
    );
    
    emit PlaylistCreated(msg.sender, playlistAddress_, msg.value);
  }

  // OWNER

  function setOwner(address owner_) external onlyOwner {
    owner = owner_;
    emit OwnerSet(msg.sender, owner_);
  }

  function setPrice(uint256 price_) external onlyOwner {
    price = price_;
    emit PriceSet(msg.sender, price_);
  }
}