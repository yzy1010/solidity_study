const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT Contract", function () {
    let NFT;
    let nft;
    let owner;
    let addr1;
    let addr2;
    let baseTokenURI = "https://api.example.com/token/";

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        NFT = await ethers.getContractFactory("NFT");
        [owner, addr1, addr2] = await ethers.getSigners();

        // Deploy the contract
        nft = await NFT.deploy("Test NFT", "TNFT", baseTokenURI);
        await nft.deployed();
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await nft.owner()).to.equal(owner.address);
        });

        it("Should set the correct name and symbol", async function () {
            expect(await nft.name()).to.equal("Test NFT");
            expect(await nft.symbol()).to.equal("TNFT");
        });

        it("Should set the base token URI", async function () {
            expect(await nft.baseTokenURI()).to.equal(baseTokenURI);
        });
    });

    describe("Minting", function () {
        it("Should allow owner to mint NFTs", async function () {
            await nft.mintNFT(addr1.address, "https://api.example.com/token/metadata/1");
            expect(await nft.ownerOf(0)).to.equal(addr1.address);
        });

        it("Should not allow non-owner to mint NFTs", async function () {
            await expect(
                nft.connect(addr1).mintNFT(addr2.address, "https://api.example.com/token/metadata/1")
            ).to.be.reverted;
        });

        it("Should increment token IDs correctly", async function () {
            await nft.mintNFT(addr1.address, "metadata1");
            await nft.mintNFT(addr1.address, "metadata2");

            expect(await nft.ownerOf(0)).to.equal(addr1.address);
            expect(await nft.ownerOf(1)).to.equal(addr1.address);
        });
    });

    describe("Token URI", function () {
        it("Should return correct token URI", async function () {
            await nft.mintNFT(addr1.address, "https://api.example.com/token/metadata/1");

            const expectedURI = baseTokenURI + "0";
            expect(await nft.tokenURI(0)).to.equal(expectedURI);
        });

        it("Should revert for non-existent token", async function () {
            await expect(nft.tokenURI(999)).to.be.revertedWith("Token does not exist");
        });
    });

    describe("Auction Integration", function () {
        it("Should allow setting auction contract address", async function () {
            await nft.setAuctionContract(addr1.address);
            expect(await nft.auctionContract()).to.equal(addr1.address);
        });

        it("Should only allow owner to set auction contract", async function () {
            await expect(
                nft.connect(addr1).setAuctionContract(addr2.address)
            ).to.be.reverted;
        });

        it("Should allow auction contract to mark token on auction", async function () {
            await nft.mintNFT(addr1.address, "metadata1");
            await nft.setAuctionContract(owner.address); // For testing, use owner as auction

            await nft.setTokenOnAuction(0, true);
            expect(await nft.isOnAuction(0)).to.equal(true);
        });

        it("Should prevent non-auction contract from setting auction status", async function () {
            await nft.mintNFT(addr1.address, "metadata1");
            await nft.setAuctionContract(owner.address);

            await expect(
                nft.connect(addr2).setTokenOnAuction(0, true)
            ).to.be.revertedWith("Only auction contract can call this");
        });
    });
});

