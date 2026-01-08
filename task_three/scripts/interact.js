const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
    console.log("🎮 NFT Auction Market Interaction Script");
    console.log("========================================\n");

    const [deployer, seller, bidder1, bidder2] = await ethers.getSigners();

    // Load deployment info
    const deploymentsDir = path.join(__dirname, "../deployments");
    const deploymentFile = path.join(deploymentsDir, `${network.name}.json`);

    if (!fs.existsSync(deploymentFile)) {
        console.error("❌ Deployment file not found. Please deploy contracts first.");
        process.exit(1);
    }

    const deploymentInfo = JSON.parse(fs.readFileSync(deploymentFile, "utf8"));

    console.log("📋 Loaded Contracts:");
    console.log("NFT:", deploymentInfo.contracts.NFT);
    console.log("Token:", deploymentInfo.contracts.MyToken);
    console.log("AuctionMarket:", deploymentInfo.contracts.AuctionMarket);
    console.log();

    // Get contract instances
    const NFT = await ethers.getContractFactory("NFT");
    const nft = NFT.attach(deploymentInfo.contracts.NFT);

    const MyToken = await ethers.getContractFactory("MyToken");
    const token = MyToken.attach(deploymentInfo.contracts.MyToken);

    const AuctionMarket = await ethers.getContractFactory("AuctionMarket");
    const auctionMarket = AuctionMarket.attach(deploymentInfo.contracts.AuctionMarket);

    try {
        console.log("🔧 Setting up interaction scenario...\n");

        // 1. Mint an NFT for the seller
        console.log("1️⃣ Minting NFT for seller...");
        await nft.mintNFT(seller.address, "https://api.example.com/metadata/my-nft");
        console.log("✅ NFT minted to seller (tokenId: 0)");

        // 2. Approve auction contract
        console.log("\n2️⃣ Setting up auction contract approval...");
        await nft.connect(seller).setApprovalForAll(auctionMarket.address, true);
        console.log("✅ Auction contract approved");

        // 3. Create auction
        console.log("\n3️⃣ Creating auction...");
        const duration = 24 * 60 * 60; // 24 hours
        const tx = await auctionMarket.connect(seller).createAuction(
            0, // tokenId
            ethers.utils.parseEther("1.0"), // starting price: 1 ETH
            ethers.utils.parseEther("1.5"), // reserve price: 1.5 ETH
            duration,
            false // ETH payment
        );
        const receipt = await tx.wait();
        console.log("✅ Auction created successfully!");

        // 4. Check auction details
        console.log("\n4️⃣ Checking auction details...");
        const auction = await auctionMarket.getAuction(1);
        console.log("   Auction ID:", auction.auctionId.toString());
        console.log("   NFT Token ID:", auction.tokenId.toString());
        console.log("   Seller:", auction.seller);
        console.log("   Starting Price:", ethers.utils.formatEther(auction.startingPrice), "ETH");
        console.log("   Reserve Price:", ethers.utils.formatEther(auction.reservePrice), "ETH");
        console.log("   End Time:", new Date(auction.endTime.toNumber() * 1000).toLocaleString());
        console.log("   Highest Bid:", ethers.utils.formatEther(auction.highestBid), "ETH");

        // 5. Fund bidders with tokens and ETH for bidding
        console.log("\n5️⃣ Funding bidders...");

        // Transfer tokens to bidders (for ERC20 auctions)
        await token.transfer(bidder1.address, ethers.utils.parseUnits("1000", 18));
        await token.transfer(bidder2.address, ethers.utils.parseUnits("1000", 18));
        console.log("✅ ERC20 tokens transferred to bidders");

        // 6. Demonstrate bid placement
        console.log("\n6️⃣ Placing bids...");

        // Bidder1 places a bid
        await auctionMarket.connect(bidder1).placeBid(1, {
            value: ethers.utils.parseEther("1.2")
        });
        console.log("✅ Bidder1 placed bid: 1.2 ETH");

        // Bidder2 places a higher bid
        await auctionMarket.connect(bidder2).placeBid(1, {
            value: ethers.utils.parseEther("1.8")
        });
        console.log("✅ Bidder2 placed higher bid: 1.8 ETH (meets reserve!)");

        // Check auction state
        const updatedAuction = await auctionMarket.getAuction(1);
        console.log("\n   Updated highest bidder:", updatedAuction.highestBidder);
        console.log("   Updated highest bid:", ethers.utils.formatEther(updatedAuction.highestBid), "ETH");

        // 7. Show pending refund for bidder1
        console.log("\n7️⃣ Checking pending refunds...");
        const refund = await auctionMarket.pendingReturns(bidder1.address, 1);
        console.log("   Bidder1 pending refund:", ethers.utils.formatEther(refund), "ETH");

        // 8. Demonstrate price feed usage (mock)
        console.log("\n8️⃣ Price feed information...");
        try {
            const prices = await auctionMarket.getCurrentPrices();
            console.log("   ETH/USD Price:", prices.ethUsd.toString());
            console.log("   ERC20/USD Price:", prices.erc20Usd.toString());
        } catch (error) {
            console.log("   ⚠️ Price feeds are mock addresses - replace with real Chainlink feeds");
        }

        // 9. ERC20 auction example
        console.log("\n9️⃣ Creating ERC20 auction example...");

        // Mint another NFT for ERC20 auction
        await nft.mintNFT(seller.address, "https://api.example.com/metadata/nft-2");

        // Create ERC20 auction
        await auctionMarket.connect(seller).createAuction(
            1, // tokenId
            ethers.utils.parseUnits("100", 18), // starting: 100 tokens
            ethers.utils.parseUnits("500", 18), // reserve: 500 tokens
            duration,
            true // ERC20 payment
        );
        console.log("✅ ERC20 auction created for tokenId 1");

        console.log("\n🎉 Interaction demo completed successfully!");
        console.log("\n📚 Next Steps:");
        console.log("1. Wait for auction duration to end, then call endAuction()");
        console.log("2. Outbid bidders can call claimRefund()");
        console.log("3. Replace mock price feeds with real Chainlink addresses");
        console.log("4. Test with real NFTs and proper metadata");

    } catch (error) {
        console.error("❌ Interaction failed:", error);
        throw error;
    }
}

// Execute interaction
if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

module.exports = main;

