// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.24;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract MockMusicNftErc721 is ERC721 {
  using Strings for uint256;
  
  constructor(string memory name_) ERC721(name_, "MUSIC") {
    _mint(msg.sender, 1);
  }

  // READ

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    return string(
      abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(abi.encodePacked(
        '{"name": "', name() , ' #', tokenId.toString(),'", ',
        '"image": "https://unblast.com/wp-content/uploads/2020/09/Musical-Album-Set-Mockup-1.jpg", ',
        '"audio_url": "ipfs://abc123/music.mp3", ',
        '"description": "A mock music NFT"',
        '}'))))
    );
  }

  // WRITE

  function mint(address to, uint256 tokenId) external {
    _mint(to, tokenId);
  }

  function burn(uint256 tokenId) external {
    _burn(tokenId);
  }

  
}