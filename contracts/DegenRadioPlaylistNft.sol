// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721, ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

interface IMetadata {
  function setDescription(uint256 tokenId_, string memory description_) external;
  function setImage(uint256 tokenId_, string memory image_) external;
  function setName(uint256 tokenId_, string memory name_) external;
}

/**
 * @title Degen Radio Playlist NFT
 * @author Tempe Techie
 * @notice Smart contract where each NFT token ID represents a Degen Radio Playlist (and an ownership of the playlist contract).
 * @notice Put the radio on the blockchain.
 */
contract DegenRadioPlaylistNft is ERC721, ERC721Enumerable, Ownable {
  address public metadataAddress; // address of the metadata contract
  string public baseUrl = "https://degenradio.lol/playlist/"; // base URL for Degen Radio website
  uint256 public counter = 1; // counter for playlist IDs

  mapping(uint256 => address) public playlists; // mapping of playlist NFT token IDs to playlist contract addresses
  mapping(address => bool) public writers; // addresses that can add playlists

  // CONSTRUCTOR
  constructor() ERC721("Degen Radio Playlists", "PLAYLISTS") Ownable(msg.sender) {}

  // READ
  function getCounter() external view returns (uint256) {
    return counter;
  }

  function getExternalUrl(uint256 tokenId_) external view returns (string memory) {
    address playlistAddress = playlists[tokenId_];
    return string(abi.encodePacked(baseUrl, playlistAddress));
  }

  function getPlaylistAddress(uint256 tokenId_) external view returns (address) {
    return playlists[tokenId_];
  }

  function isWriter(address writer_) external view returns (bool) {
    return writers[writer_];
  }

  // WRITER
  /**
   * @notice Creates a new Degen Radio Playlist
   * @param playlistAddress_ Address of the new playlist
   * @param name_ Name of the playlist
   * @param description_ Description of the playlist
   * @param image_ Image of the playlist
   */
  function addPlaylist(
    address playlistAddress_,
    address playlistOwner_,
    string memory name_,
    string memory description_,
    string memory image_
  ) external onlyOwner {
    require(writers[msg.sender], "DegenRadioPlaylistNft: caller is not a writer");

    playlists[counter] = playlistAddress_;
    _safeMint(playlistOwner_, counter);

    IMetadata(metadataAddress).setName(counter, name_);
    IMetadata(metadataAddress).setDescription(counter, description_);
    IMetadata(metadataAddress).setImage(counter, image_);

    counter++;
  }

  // OWNER
  function addWriter(address writer_) external onlyOwner {
    writers[writer_] = true;
  }

  function removeWriter(address writer_) external onlyOwner {
    writers[writer_] = false;
  }

  function setBaseUrl(string memory baseUrl_) external onlyOwner {
    baseUrl = baseUrl_;
  }

  function setMetadataAddress(address metadataAddress_) external onlyOwner {
    metadataAddress = metadataAddress_;
  }

  // OVERRIDES (the following functions are overrides required by OpenZeppelin contracts)

  function _update(address to, uint256 tokenId, address auth)
      internal
      override(ERC721, ERC721Enumerable)
      returns (address)
  {
      return super._update(to, tokenId, auth);
  }

  function _increaseBalance(address account, uint128 value)
      internal
      override(ERC721, ERC721Enumerable)
  {
      super._increaseBalance(account, value);
  }

  function supportsInterface(bytes4 interfaceId)
      public
      view
      override(ERC721, ERC721Enumerable)
      returns (bool)
  {
      return super.supportsInterface(interfaceId);
  }
}