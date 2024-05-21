// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.24;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

interface INFT {
  function getExternalUrl(uint256 tokenId_) external view returns (string memory);
  function getPlaylistAddress(uint256 tokenId_) external view returns (address);
  function ownerOf(uint256 tokenId) external view returns (address);
}

interface IPlaylist {
  function isManager(address manager_) external view returns (bool);
}

interface IState {
  function getDescription(uint256 tokenId_) external view returns (string memory);
  function getGenre(uint256 tokenId_) external view returns (string memory);
  function getImage(uint256 tokenId_) external view returns (string memory);
  function getName(uint256 tokenId_) external view returns (string memory);
  function mds(uint256) external view returns (string memory description, string memory genre, string memory image, string memory name);
  function setDescription(uint256 tokenId_, string memory description_) external;
  function setGenre(uint256 tokenId_, string memory genre_) external;
  function setImage(uint256 tokenId_, string memory image_) external;
  function setName(uint256 tokenId_, string memory name_) external;
}

/** 
@title Default metadata contract for Degen Radio Playlist Ownership NFTs
@author Tempe Techie
@notice Put the radio on the blockchain.
*/
contract DegenRadioMetadata {
  using Strings for uint256;

  address public immutable mdStateAddress; // address of the metadata state smart contract
  address public immutable playlistNftAddress; // address of the Playlist NFT smart contract

  // MODIFIERS
  modifier onlyTokenHolder(uint256 tokenId_) {
    address playlistAddress = INFT(playlistNftAddress).getPlaylistAddress(tokenId_);

    require(
      msg.sender == INFT(playlistNftAddress).ownerOf(tokenId_) || // playlist owner
      IPlaylist(playlistAddress).isManager(msg.sender) || // playlist manager
      msg.sender == playlistNftAddress, // playlist NFT contract itself
      "Not owner of NFT token"
    );
    _;
  }

  // EVENTS
  event DescriptionSet(address indexed caller_, uint256 indexed tokenId_);
  event GenreSet(address indexed caller_, uint256 indexed tokenId_);
  event ImageSet(address indexed caller_, uint256 indexed tokenId_);
  event NameSet(address indexed caller_, uint256 indexed tokenId_);

  // CONSTRUCTOR
  constructor(address mdStateAddress_, address playlistNftAddress_) {
    mdStateAddress = mdStateAddress_;
    playlistNftAddress = playlistNftAddress_;
  }

  // READ

  function getDescription(uint256 tokenId_) external view returns (string memory) {
    return IState(mdStateAddress).getDescription(tokenId_);
  }

  function getExternalUrl(uint256 tokenId_) external view returns (string memory) {
    return INFT(playlistNftAddress).getExternalUrl(tokenId_);
  }

  function getGenre(uint256 tokenId_) external view returns (string memory) {
    return IState(mdStateAddress).getGenre(tokenId_);
  }

  function getImage(uint256 tokenId_) external view returns (string memory) {
    return IState(mdStateAddress).getImage(tokenId_);
  }

  function getMetadata(uint256 tokenId_) external view returns (string memory) {
    (string memory description_, string memory genre_, string memory image_, string memory name_) = IState(mdStateAddress).mds(tokenId_);

    return string(
      abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(abi.encodePacked(
        //'{"name": "', name_,' #', tokenId_.toString(),'", ',
        '{"name": "', name_,'", ',
        '"image": "', image_, '", ',
        '"genre": "', genre_, '", ',
        _getPlaylistAddressAndExternalUrl(tokenId_),
        '"description": "', description_, '"}'
      ))))
    );
  }

  function getName(uint256 tokenId_) external view returns (string memory) {
    return IState(mdStateAddress).getName(tokenId_);
  }

  function getPlaylistAddress(uint256 tokenId_) external view returns (address) {
    return INFT(playlistNftAddress).getPlaylistAddress(tokenId_);
  }

  // INTERNAL
  function _getPlaylistAddressAndExternalUrl(uint256 tokenId_) internal view returns (string memory) {
    string memory addrStr = Strings.toHexString(uint256(uint160(INFT(playlistNftAddress).getPlaylistAddress(tokenId_))), 20);

    return string(abi.encodePacked(
      '"external_url": "', INFT(playlistNftAddress).getExternalUrl(tokenId_), '", ',
      '"playlist_address": "', addrStr, '", '
    ));
  }

  // WRITE (TOKEN HOLDERS ONLY)

  function setDescription(uint256 tokenId_, string memory description_) external onlyTokenHolder(tokenId_) {
    IState(mdStateAddress).setDescription(tokenId_, description_);
    emit DescriptionSet(msg.sender, tokenId_);
  }

  function setGenre(uint256 tokenId_, string memory genre_) external onlyTokenHolder(tokenId_) {
    IState(mdStateAddress).setGenre(tokenId_, genre_);
    emit GenreSet(msg.sender, tokenId_);
  }

  function setImage(uint256 tokenId_, string memory image_) external onlyTokenHolder(tokenId_) {
    IState(mdStateAddress).setImage(tokenId_, image_);
    emit ImageSet(msg.sender, tokenId_);
  }

  function setName(uint256 tokenId_, string memory name_) external onlyTokenHolder(tokenId_) {
    IState(mdStateAddress).setName(tokenId_, name_);
    emit NameSet(msg.sender, tokenId_);
  }

}