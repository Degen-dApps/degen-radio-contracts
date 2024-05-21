// npx hardhat test test/degenRadio.test.js

const { expect } = require("chai");

describe("Degen Radio test", function () {
  let musicNftContract1;
  let musicNftContract1Name = "First song";
  let musicNftContract2;
  let musicNftContract2Name = "Second song";
  let musicNftContract3;
  let musicNftContract3Name = "Third song";

  let factoryContract;
  let metadataContract;
  let metadataStateContract;
  let playlistNftContract;

  beforeEach(async function () {
    [ owner, user1, user2 ] = await ethers.getSigners();

    const MockMusicNftErc721 = await ethers.getContractFactory("MockMusicNftErc721");

    musicNftContract1 = await MockMusicNftErc721.deploy(musicNftContract1Name);
    await musicNftContract1.deployed();

    musicNftContract2 = await MockMusicNftErc721.deploy(musicNftContract2Name);
    await musicNftContract2.deployed();

    musicNftContract3 = await MockMusicNftErc721.deploy(musicNftContract3Name);
    await musicNftContract3.deployed();

    const DegenRadioPlaylistNft = await ethers.getContractFactory("DegenRadioPlaylistNft");
    playlistNftContract = await DegenRadioPlaylistNft.deploy();
    await playlistNftContract.deployed();

    const DegenRadioMetadataState = await ethers.getContractFactory("DegenRadioMetadataState");
    metadataStateContract = await DegenRadioMetadataState.deploy();
    await metadataStateContract.deployed();

    const DegenRadioMetadata = await ethers.getContractFactory("DegenRadioMetadata");
    metadataContract = await DegenRadioMetadata.deploy(metadataStateContract.address, playlistNftContract.address);
    await metadataContract.deployed();

    await metadataStateContract.addWriter(metadataContract.address);
    await playlistNftContract.setMetadataAddress(metadataContract.address);

    const DegenRadioFactory = await ethers.getContractFactory("DegenRadioFactory");
    factoryContract = await DegenRadioFactory.deploy(playlistNftContract.address);
    await factoryContract.deployed();

    // Add factory as writer to playlistNftContract
    await playlistNftContract.addWriter(factoryContract.address);
  });

  // check initial state variables
  it("Should have correct initial state variables", async function () {
    console.log(" "); // empty line in console

    let playlistNftMetadataAddress = await playlistNftContract.metadataAddress();
    expect(playlistNftMetadataAddress).to.equal(metadataContract.address);

    let isFactoryWriter = await playlistNftContract.isWriter(factoryContract.address);
    expect(isFactoryWriter).to.equal(true);

    let metadataPlaylistNftAddress = await metadataContract.playlistNftAddress();
    expect(metadataPlaylistNftAddress).to.equal(playlistNftContract.address);

    let factoryOwner = await factoryContract.owner();
    expect(factoryOwner).to.equal(owner.address);

    let factoryPlaylistNftAddress = await factoryContract.playlistNftAddress();
    expect(factoryPlaylistNftAddress).to.equal(playlistNftContract.address);

    let factoryPrice = await factoryContract.price();
    expect(factoryPrice).to.equal(ethers.utils.parseEther("0"));

    let musicNftName1 = await musicNftContract1.name();
    expect(musicNftName1).to.equal(musicNftContract1Name);

    let musicNft1Metadata = await musicNftContract1.tokenURI(1);
    //console.log(musicNft1Metadata);

    // decode musicNft1Metadata base64 string
    musicNft1Metadata = musicNft1Metadata.split(",")[1];
    musicNft1Metadata = Buffer.from(musicNft1Metadata, "base64").toString();
    //console.log(musicNft1Metadata);
    //console.log(JSON.parse(musicNft1Metadata).name);
    expect(JSON.parse(musicNft1Metadata).name).to.equal(musicNftContract1Name + " #1");
  });

  // check owners of all contracts
  it("The owner address should be the owner of DegenRadioFactory, DegenRadioMetadataState & DegenRadioPlaylistNft", async function () {
    console.log(" "); // empty line in console
    let factoryOwner = await factoryContract.owner();
    expect(factoryOwner).to.equal(owner.address);

    let metadataStateOwner = await metadataStateContract.owner();
    expect(metadataStateOwner).to.equal(owner.address);

    let playlistNftOwner = await playlistNftContract.owner();
    expect(playlistNftOwner).to.equal(owner.address);
  });

  // create a playlist
  it("Should create a playlist", async function () {
    console.log(" "); // empty line in console

    let playlistId = 1;
    let playlistName = "First playlist";
    let playlistDescription = "This is the first playlist";
    let playlistImage = "https://blog.hootsuite.com/wp-content/uploads/2022/09/How-to-make-a-playlist-on-tiktok.png";

    // get price to create a playlist
    let factoryPrice = await factoryContract.price();
    expect(factoryPrice).to.equal(ethers.utils.parseEther("0"));
    console.log("Factory price to create a playlist:", ethers.utils.formatEther(factoryPrice));

    await factoryContract.createPlaylist(
      playlistName, 
      playlistDescription,
      playlistImage,
      musicNftContract1.address, // track address
      1, // track token ID (if not found, use 1)
      1, // track type (1: ERC721 with same metadata, 2: ERC721 with different metadata, 3: ERC1155)
      { value: factoryPrice }
    );

    let playlistMetadata = await playlistNftContract.tokenURI(playlistId);
    //console.log(playlistMetadata);

    let playlistAddress = await playlistNftContract.getPlaylistAddress(playlistId);
    console.log("Playlist address:", playlistAddress);

    // decode playlistMetadata base64 string
    playlistMetadata = playlistMetadata.split(",")[1];
    playlistMetadata = Buffer.from(playlistMetadata, "base64").toString();
    console.log(playlistMetadata);
    //console.log(JSON.parse(playlistMetadata).name);
    expect(JSON.parse(playlistMetadata).name).to.equal(playlistName);

    // check owner of playlist NFT
    let playlistOwner = await playlistNftContract.ownerOf(playlistId);
    expect(playlistOwner).to.equal(owner.address);

    // check owners balance of playlist NFTs
    let ownerBalance = await playlistNftContract.balanceOf(owner.address);
    expect(ownerBalance).to.equal(1);

    // check which NFT IDs owner owns (tokenOfOwnerByIndex)
    let playlistIdOfOwner = await playlistNftContract.tokenOfOwnerByIndex(owner.address, 0);
    expect(playlistIdOfOwner).to.equal(playlistId);

    // expect a revert (ERC721OutOfBoundsIndex) for index 1
    await expect(playlistNftContract.tokenOfOwnerByIndex(owner.address, 1)).to.be.reverted;

    // create playlist contract instance
    const DegenRadioPlaylist = await ethers.getContractFactory("DegenRadioPlaylist");
    const playlistContract = await DegenRadioPlaylist.attach(playlistAddress);

    // get managers list before
    const managersBefore = await playlistContract.getManagers();
    expect(managersBefore.length).to.equal(0);

    // add user1 as manager
    await playlistContract.addManager(user1.address);

    // get managers list after
    const managersAfter = await playlistContract.getManagers();
    expect(managersAfter.length).to.equal(1);

    // get up to 5 latest tracks in DegenRadioPlaylist.sol
    const lastTracks1 = await playlistContract.getLastTracks(5);
    //console.log("Last 5 tracks:", lastTracks1);
    expect(lastTracks1.length).to.equal(1);

    // get track with index 0
    const track = await playlistContract.getTrack(0);
    console.log("Track:", track.nftAddress);
    expect(track.nftAddress).to.equal(musicNftContract1.address);

    // get track with index 1 (expect a revert)
    await expect(playlistContract.getTrack(1)).to.be.reverted;

    // get track data for track with index 0
    const trackData = await playlistContract.getTrackData(0);
    //console.log("Track data:", trackData);
    expect(trackData.nftAddress).to.equal(musicNftContract1.address);

    // add one more track to the playlist
    await playlistContract.addTrack(
      musicNftContract2.address, // track address
      1, // track token ID (if not found, use 1)
      1, // track type (1: ERC721 with same metadata, 2: ERC721 with different metadata, 3: ERC1155)
    );

    const lastTracks2 = await playlistContract.getLastTracks(5);
    //console.log("Last 5 tracks:", lastTracks2);
    expect(lastTracks2.length).to.equal(2);

    // manager adds one more track to the playlist
    await playlistContract.connect(user1).addTrack(
      musicNftContract3.address, // track address
      1, // track token ID (if not found, use 1)
      1, // track type (1: ERC721 with same metadata, 2: ERC721 with different metadata, 3: ERC1155)
    );

    const lastTracks3 = await playlistContract.getLastTracks(5);
    //console.log("Last 5 tracks:", lastTracks3);
    expect(lastTracks3.length).to.equal(3);

    // manager removes track with index 2
    await playlistContract.connect(user1).removeTrackByIndex(1);

    const lastTracks4 = await playlistContract.getLastTracks(5);
    //console.log("Last 5 tracks:", lastTracks4);
    expect(lastTracks4.length).to.equal(2);

    // get playlist genre from metadata contract before
    const playlistGenreBefore = await metadataContract.getGenre(playlistId);
    console.log("Playlist genre before:", playlistGenreBefore);
    expect(playlistGenreBefore).to.equal("");
    
    let track1Genre = "Rock";
    await metadataContract.setGenre(playlistId, track1Genre);

    // get playlist genre from metadata contract after
    const playlistGenreAfter = await metadataContract.getGenre(playlistId);
    console.log("Playlist genre after owner's change:", playlistGenreAfter);

    // manager updates genre
    track1Genre = "Pop";
    await metadataContract.connect(user1).setGenre(playlistId, track1Genre);

    // get playlist genre from metadata contract after2
    const playlistGenreAfter2 = await metadataContract.getGenre(playlistId);
    console.log("Playlist genre after manager's change:", playlistGenreAfter2);
    expect(playlistGenreAfter2).to.equal(track1Genre);

    // fetch metadata again
    playlistMetadata = await playlistNftContract.tokenURI(playlistId);

    // decode playlistMetadata base64 string
    playlistMetadata = playlistMetadata.split(",")[1];
    playlistMetadata = Buffer.from(playlistMetadata, "base64").toString();
    //console.log(playlistMetadata);
    expect(JSON.parse(playlistMetadata).genre).to.equal(track1Genre);

    // remove user1 as manager
    await playlistContract.removeManagerByAddress(user1.address);
    
    // get managers list after2
    const managersAfter2 = await playlistContract.getManagers();
    expect(managersAfter2.length).to.equal(0);
  });

  // TODO: 
  // - change custom order of tracks in playlist
  // - getExternalUrl from playlist NFT contract

});