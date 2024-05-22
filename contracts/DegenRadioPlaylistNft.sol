// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { ERC721, ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { OwnableWithManagers } from "./access/OwnableWithManagers.sol";

interface IMetadata {
  function getMetadata(uint256 tokenId_) external view returns (string memory);
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
contract DegenRadioPlaylistNft is ERC721, ERC721Enumerable, OwnableWithManagers {
  address public metadataAddress; // address of the metadata contract
  string public baseUrl = "https://degenradio.lol/playlist/"; // base URL for Degen Radio website
  uint256 public counter = 1; // counter for playlist IDs

  mapping(uint256 => address) public playlists; // mapping of playlist NFT token IDs to playlist contract addresses
  mapping(address => bool) public writers; // addresses that can add playlists

  // MODIFIERS
  modifier onlyWriter() {
    require(writers[msg.sender], "DegenRadioPlaylistNft: caller is not a writer");
    _;
  }

  // EVENTS
  event BaseUrlSet(address indexed caller_);
  event MetadataAddressSet(address indexed caller_, address indexed metadataAddress_);
  event WriterAdded(address indexed caller_, address indexed writer_);
  event WriterRemoved(address indexed caller_, address indexed writer_);

  // CONSTRUCTOR
  constructor() ERC721("Degen Radio Playlists", "PLAYLISTS") {}

  // READ
  function getCounter() external view returns (uint256) {
    return counter;
  }

  function getExternalUrl(uint256 tokenId_) external view returns (string memory) {
    address playlistAddress = playlists[tokenId_];
    string memory addrStr = Strings.toHexString(uint256(uint160(playlistAddress)), 20);
    return string(abi.encodePacked(baseUrl, addrStr));
  }

  function getLastPlaylists(uint256 amount_) external view returns (address[] memory) {
    if (amount_ > counter - 1) {
      amount_ = counter - 1;
    }

    address[] memory lastPlaylists = new address[](amount_);

    for (uint256 i = 0; i < amount_; i++) {
      lastPlaylists[i] = playlists[counter - 1 - i];
    }
    
    return lastPlaylists;
  }

  function getPlaylistAddress(uint256 tokenId_) external view returns (address) {
    return playlists[tokenId_];
  }

  function isWriter(address writer_) external view returns (bool) {
    return writers[writer_];
  }

  function tokenURI(uint256 tokenId_) public view override returns (string memory) {
    return IMetadata(metadataAddress).getMetadata(tokenId_);
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
  ) external onlyWriter {
    require(writers[msg.sender], "DegenRadioPlaylistNft: caller is not a writer");

    playlists[counter] = playlistAddress_;
    _safeMint(playlistOwner_, counter);

    IMetadata(metadataAddress).setName(counter, name_);
    IMetadata(metadataAddress).setDescription(counter, description_);
    IMetadata(metadataAddress).setImage(counter, image_);

    counter++;
  }

  // OWNER
  function addWriter(address writer_) external onlyManagerOrOwner {
    writers[writer_] = true;
    emit WriterAdded(msg.sender, writer_);
  }

  function removeWriter(address writer_) external onlyManagerOrOwner {
    writers[writer_] = false;
    emit WriterRemoved(msg.sender, writer_);
  }

  function setBaseUrl(string memory baseUrl_) external onlyManagerOrOwner {
    baseUrl = baseUrl_;
    emit BaseUrlSet(msg.sender);
  }

  function setMetadataAddress(address metadataAddress_) external onlyManagerOrOwner {
    metadataAddress = metadataAddress_;
    emit MetadataAddressSet(msg.sender, metadataAddress_);
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