// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import { OwnableWithManagers } from "./access/OwnableWithManagers.sol";

/** 
@title Smart contract that holds metadata state for Degen Radio Playlist Ownership NFTs
@author Tempe Techie
@notice Put the radio on the blockchain.
*/
contract DegenRadioMetadataState is OwnableWithManagers {
  
  struct Metadata {
    string description;
    string genre;
    string image;
    string name;
  }

  mapping (uint256 => Metadata) public mds; // NFT token ID to metadata
  mapping (address => bool) public writers; // writers are addresses that can modify metadata

  // MODIFIERS
  modifier onlyWriter() {
    require(writers[msg.sender], "Not a writer");
    _;
  }

  // EVENTS
  event DescriptionSet(address indexed caller_, uint256 indexed tokenId_);
  event GenreSet(address indexed caller_, uint256 indexed tokenId_);
  event ImageSet(address indexed caller_, uint256 indexed tokenId_);
  event NameSet(address indexed caller_, uint256 indexed tokenId_);
  event WriterAdded(address indexed caller_, address indexed writer_);
  event WriterRemoved(address indexed caller_, address indexed writer_);

  // READ

  function getDescription(uint256 tokenId_) external view returns (string memory) {
    return mds[tokenId_].description;
  }

  function getGenre(uint256 tokenId_) external view returns (string memory) {
    return mds[tokenId_].genre;
  }

  function getImage(uint256 tokenId_) external view returns (string memory) {
    return mds[tokenId_].image;
  }

  function getName(uint256 tokenId_) external view returns (string memory) {
    return mds[tokenId_].name;
  }

  // WRITE (WRITERS ONLY)

  function setDescription(uint256 tokenId_, string memory description_) external onlyWriter {
    mds[tokenId_].description = description_;
    emit DescriptionSet(msg.sender, tokenId_);
  }

  function setGenre(uint256 tokenId_, string memory genre_) external onlyWriter {
    mds[tokenId_].genre = genre_;
    emit GenreSet(msg.sender, tokenId_);
  }

  function setImage(uint256 tokenId_, string memory image_) external onlyWriter {
    mds[tokenId_].image = image_;
    emit ImageSet(msg.sender, tokenId_);
  }

  function setName(uint256 tokenId_, string memory name_) external onlyWriter {
    mds[tokenId_].name = name_;
    emit NameSet(msg.sender, tokenId_);
  }

  // MANAGER OR OWNER

  function addWriter(address writer_) external onlyManagerOrOwner {
    writers[writer_] = true;
    emit WriterAdded(msg.sender, writer_);
  }

  function removeWriter(address writer_) external onlyManagerOrOwner {
    writers[writer_] = false;
    emit WriterRemoved(msg.sender, writer_);
  }

}