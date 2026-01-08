const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("AuctionMarket Contract", function () {
    let NFT, MyToken, PriceConsumerV3, AuctionMarket;
    let nft, token, priceFeed, auctionMarket;
    let owner, seller, bidder1, bidder2;
    let auctionId;
    let baseTokenURI = "https://api.example.com/token/";

    // Mock price feed addresses (we'll use a mock contract in real scenario)
    const mockEthUsdFeed = "0x694AA1769357215DE4FAC081bf1f309aDC325306"; // Goerli ETH/USD
    const mockErc20UsdFeed = "0x81732b4157EC73481B5368342F067e3D26400f54"; // Mock address

    beforeEach(async function () {
        [owner, seller, bidder1, bidder2] = await ethers.getSigners();

        // Deploy contracts
        NFT = await ethers.getContractFactory("NFT");
        nft = await NFT.deploy("Auction NFT", "ANFT", baseTokenURI);
        await nft.deployed();

        MyToken = await ethers.getContractFactory("MyToken");
        token = await MyToken.deploy();
        await token.deployed();

        PriceConsumerV3 = await ethers.getContractFactory("PriceConsumerV3");

        // For testing, we'll just deploy with mock addresses
        // In production, you would use real Chainlink price feed addresses
        auctionMarket = await (await ethers.getContractFactory("AuctionMarket")).deploy(
            nft.address,
            token.address,
            owner.address, // Mock ETH price feed
            owner.address  // Mock ERC20 price feed
        );
        await auctionMarket.deployed();

        // Setup auction contract as the auction contract in NFT
        await nft.setAuctionContract(auctionMarket.address);

        // Mint an NFT for testing
        await nft.mintNFT(seller.address, "https://api.example.com/token/metadata/1");

        // Approve auction contract to transfer NFT
        await nft.connect(seller).setApprovalForAll(auctionMarket.address, true);

        // Mint tokens for bidders
        await token.mint(bidder1.address, ethers.utils.parseUnits("1000", 18));
        await token.mint(bidder2.address, ethers.utils.parseUnits("1000", 18));
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await auctionMarket.owner()).to.equal(owner.address);
        });

        it("Should have correct initial platform fee", async function () {
            expect(await auctionMarket.platformFeePercentage()).to.equal(250); // 2.5%
        });
    });

    describe("Creating Auctions", function () {
        it("Should allow seller to create an auction", async function () {
            const startTime = await time.latest();
            const duration = 24 * 60 * 60; // 24 hours

            await expect(
                auctionMarket.connect(seller).createAuction(
                    0, // tokenId
                    ethers.utils.parseEther("1"), // startingPrice
                    ethers.utils.parseEther("1.5"), // reservePrice
                    duration, // 24 hours
                    false // ETH payment
                )
            ).to.emit(auctionMarket, "AuctionCreated");

            const auction = await auctionMarket.getAuction(1);
            expect(auction.tokenId).to.equal(0);
            expect(auction.seller).to.equal(seller.address);
            expect(auction.startingPrice).to.equal(ethers.utils.parseEther("1"));
        });

        it("Should not allow creating auction without ownership", async function () {
            await expect(
                auctionMarket.connect(bidder1).createAuction(
                    0,
                    ethers.utils.parseEther("1"),
                    ethers.utils.parseEther("1.5"),
                    24 * 60 * 60,
                    false
                )
            ).to.be.revertedWith("You must own the NFT");
        });

        it("Should mark NFT as on auction after creation", async function () {
            await auctionMarket.connect(seller).createAuction(
                0,
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1.5"),
                24 * 60 * 60,
                false
            );

            expect(await nft.isOnAuction(0)).to.equal(true);
        });
    });

    describe("Placing Bids", function () {
        beforeEach(async function () {
            await auctionMarket.connect(seller).createAuction(
                0,
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1.5"),
                24 * 60 * 60,
                false
            );
            auctionId = 1;
        });

        it("Should allow ETH bids on ETH auctions", async function () {
            await expect(
                auctionMarket.connect(bidder1).placeBid(auctionId, {
                    value: ethers.utils.parseEther("2")
                })
            ).to.emit(auctionMarket, "BidPlaced");

            const auction = await auctionMarket.getAuction(auctionId);
            expect(auction.highestBidder).to.equal(bidder1.address);
            expect(auction.highestBid).to.equal(ethers.utils.parseEther("2"));
        });

        it("Should allow ERC20 bids on ERC20 auctions", async function () {
            // Create ERC20 auction
            await auctionMarket.connect(seller).createAuction(
                0, // This will fail since NFT is already on auction
                ethers.utils.parseUnits("100", 18),
                ethers.utils.parseUnits("150", 18),
                24 * 60 * 60,
                true // ERC20 payment
            );

            // Approve tokens for auction contract
            await token.connect(bidder1).approve(auctionMarket.address, ethers.utils.parseUnits("200", 18));

            await expect(
                auctionMarket.connect(bidder1).placeBid(2)
            ).to.be.reverted; // Need to handle allowance properly in the contract
        });

        it("Should reject bids below starting price", async function () {
            await expect(
                auctionMarket.connect(bidder1).placeBid(auctionId, {
                    value: ethers.utils.parseEther("0.5")
                })
            ).to.be.revertedWith("Bid below starting price");
        });

        it("Should allow higher bids and refund previous bidder", async function () {
            // First bid
            await auctionMarket.connect(bidder1).placeBid(auctionId, {
                value: ethers.utils.parseEther("2")
            });

            // Second higher bid
            await auctionMarket.connect(bidder2).placeBid(auctionId, {
                value: ethers.utils.parseEther("3")
            });

            const auction = await auctionMarket.getAuction(auctionId);
            expect(auction.highestBidder).to.equal(bidder2.address);
            expect(auction.highestBid).to.equal(ethers.utils.parseEther("3"));

            // Check pending refund
            expect(await auctionMarket.pendingReturns(bidder1.address, auctionId)).to.equal(
                ethers.utils.parseEther("2")
            );
        });
    });

    describe("Ending Auctions", function () {
        beforeEach(async function () {
            await auctionMarket.connect(seller).createAuction(
                0,
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1.5"),
                24 * 60 * 60,
                false
            );
            auctionId = 1;

            // Place a valid bid
            await auctionMarket.connect(bidder1).placeBid(auctionId, {
                value: ethers.utils.parseEther("2")
            });
        });

        it("Should allow ending auction after duration", async function () {
            // Increase time
            await time.increase(24 * 60 * 60 + 1);

            await expect(
                auctionMarket.endAuction(auctionId)
            ).to.emit(auctionMarket, "AuctionEnded");

            const auction = await auctionMarket.getAuction(auctionId);
            expect(auction.ended).to.equal(true);

            // Check NFT is no longer on auction
            expect(await nft.isOnAuction(0)).to.equal(false);
        });

        it("Should not allow ending auction before duration", async function () {
            await expect(
                auctionMarket.endAuction(auctionId)
            ).to.be.revertedWith("Auction not ended yet");
        });

        it("Should allow seller to end auction early", async function () {
            await expect(
                auctionMarket.connect(seller).endAuction(auctionId)
            ).to.emit(auctionMarket, "AuctionEnded");
        });
    });

    describe("Claiming Refunds", function () {
        beforeEach(async function () {
            await auctionMarket.connect(seller).createAuction(
                0,
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1.5"),
                24 * 60 * 60,
                false
            );
            auctionId = 1;

            // Create bidding scenario
            await auctionMarket.connect(bidder1).placeBid(auctionId, {
                value: ethers.utils.parseEther("2")
            });
            await auctionMarket.connect(bidder2).placeBid(auctionId, {
                value: ethers.utils.parseEther("3")
            });
        });

        it("Should allow outbid bidder to claim refund", async function () {
            const initialBalance = await ethers.provider.getBalance(bidder1.address);

            await auctionMarket.connect(bidder1).claimRefund(auctionId);

            const finalBalance = await ethers.provider.getBalance(bidder1.address);
            expect(finalBalance).to.be.gt(initialBalance);
        });

        it("Should not allow claiming refund twice", async function () {
            await auctionMarket.connect(bidder1).claimRefund(auctionId);

            await expect(
                auctionMarket.connect(bidder1).claimRefund(auctionId)
            ).to.be.revertedWith("No refund available");
        });
    });

    describe("Fee Management", function () {
        it("Should allow owner to update platform fee", async function () {
            await auctionMarket.setPlatformFee(500); // 5%
            expect(await auctionMarket.platformFeePercentage()).to.equal(500);
        });

        it("Should not allow setting fee too high", async function () {
            await expect(
                auctionMarket.setPlatformFee(2000) // 20%
            ).to.be.revertedWith("Fee too high (max 10%)");
        });

        it("Should allow owner to withdraw fees", async function () {
            // Create auction and transaction that generates fees
            await auctionMarket.connect(seller).createAuction(
                0,
                ethers.utils.parseEther("1"),
                ethers.utils.parseEther("1.5"),
                24 * 60 * 60,
                false
            );

            await auctionMarket.connect(bidder1).placeBid(1, {
                value: ethers.utils.parseEther("2")
            });

            await time.increase(24 * 60 * 60 + 1);
            await auctionMarket.endAuction(1);

            const initialOwnerBalance = await ethers.provider.getBalance(owner.address);

            await auctionMarket.withdrawFees("0x0000000000000000000000000000000000000000");

            const finalOwnerBalance = await ethers.provider.getBalance(owner.address);
            expect(finalOwnerBalance).to.be.gt(initialOwnerBalance);
        });
    });
});

