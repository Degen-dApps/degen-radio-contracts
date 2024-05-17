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
  }

  function setGenre(uint256 tokenId_, string memory genre_) external onlyWriter {
    mds[tokenId_].genre = genre_;
  }

  function setImage(uint256 tokenId_, string memory image_) external onlyWriter {
    mds[tokenId_].image = image_;
  }

  function setName(uint256 tokenId_, string memory name_) external onlyWriter {
    mds[tokenId_].name = name_;
  }

  // MANAGER OR OWNER

  function addWriter(address writer_) external onlyManagerOrOwner {
    writers[writer_] = true;
  }

  function removeWriter(address writer_) external onlyManagerOrOwner {
    writers[writer_] = false;
  }

}