// npx hardhat test test/degenRadio.test.js

const { expect } = require("chai");

describe("Degen Radio test", function () {
  let musicNftContract1;
  let musicNftContract1Name = "First song";
  let musicNftContract2;
  let musicNftContract2Name = "Second song";
  let musicNftContract3;
  let musicNftContract3Name = "Third song";

  let playlistNftContract;
  let metadataContract;
  let factoryContract;

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

    const DegenRadioMetadata = await ethers.getContractFactory("DegenRadioMetadata");
    metadataContract = await DegenRadioMetadata.deploy(playlistNftContract.address);
    await metadataContract.deployed();

    await playlistNftContract.setMetadataAddress(metadataContract.address);

    const DegenRadioFactory = await ethers.getContractFactory("DegenRadioFactory");
    factoryContract = await DegenRadioFactory.deploy(playlistNftContract.address);
    await factoryContract.deployed();

    // Add factory as writer to playlistNftContract
    await playlistNftContract.addWriter(factoryContract.address);
  });

  it("should have correct initial state variables", async function () {
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

});