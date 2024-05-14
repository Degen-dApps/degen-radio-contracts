// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

interface INFT {
  function getExternalUrl(uint256 tokenId_) external view returns (string memory);
  function getPlaylistAddress(uint256 tokenId_) external view returns (address);
  function ownerOf(uint256 tokenId) external view returns (address);
}

/** 
@title Default metadata contract for Degen Radio Playlist Ownership NFTs
@author Tempe Techie
@notice Put the radio on the blockchain.
*/
contract DegenRadioMetadata {
  using Strings for uint256;

  address public immutable playlistNftAddress; // address of the Playlist NFT smart contract

  struct Metadata {
    string name;
    string description;
    string image;
  }

  mapping (uint256 => Metadata) public mds; // NFT token ID to metadata

  // MODIFIERS
  modifier onlyTokenHolder(uint256 tokenId_) {
    require(
      msg.sender == INFT(playlistNftAddress).ownerOf(tokenId_) || 
      msg.sender == playlistNftAddress, 
      "Not owner of NFT token"
    );
    _;
  }

  // CONSTRUCTOR
  constructor(address playlistNftAddress_) {
    playlistNftAddress = playlistNftAddress_;
  }

  // READ

  function getDescription(uint256 tokenId_) external view returns (string memory) {
    return mds[tokenId_].description;
  }

  function getExternalUrl(uint256 tokenId_) external view returns (string memory) {
    return INFT(playlistNftAddress).getExternalUrl(tokenId_);
  }

  function getImage(uint256 tokenId_) external view returns (string memory) {
    return mds[tokenId_].image;
  }

  function getMetadata(uint256 tokenId_) external view returns (string memory) {
    return string(
      abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(abi.encodePacked(
        '{"name": "', mds[tokenId_].name,' #', tokenId_.toString(),'", ',
        '"image": "', mds[tokenId_].image, '", ',
        '"external_url": "', INFT(playlistNftAddress).getExternalUrl(tokenId_), '", ',
        '"playlist_address": "', INFT(playlistNftAddress).getPlaylistAddress(tokenId_), '", ',
        '"description": "', mds[tokenId_].description, '"',
        '}'))))
    );
  }

  function getName(uint256 tokenId_) external view returns (string memory) {
    return mds[tokenId_].name;
  }

  function getPlaylistAddress(uint256 tokenId_) external view returns (address) {
    return INFT(playlistNftAddress).getPlaylistAddress(tokenId_);
  }

  // WRITE (TOKEN HOLDERS ONLY)

  function setDescription(uint256 tokenId_, string memory description_) external onlyTokenHolder(tokenId_) {
    mds[tokenId_].description = description_;
  }

  function setImage(uint256 tokenId_, string memory image_) external onlyTokenHolder(tokenId_) {
    mds[tokenId_].image = image_;
  }

  function setName(uint256 tokenId_, string memory name_) external onlyTokenHolder(tokenId_) {
    mds[tokenId_].name = name_;
  }

}