const { ethers, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
    console.log("🚀 Starting deployment...");

    // Get the deployer's signer
    const [deployer] = await ethers.getSigners();
    console.log("📝 Deploying contracts with the account:", deployer.address);

    // Get account balance
    const balance = await deployer.getBalance();
    console.log("💰 Account balance:", ethers.utils.formatEther(balance), "ETH");

    try {
        // Deploy NFT Contract
        console.log("\n🎨 Deploying NFT contract...");
        const NFT = await ethers.getContractFactory("NFT");
        const nft = await NFT.deploy(
            "Auction NFT Collection",
            "AUC-NFT",
            "https://api.example.com/token/"
        );
        await nft.deployed();
        console.log("✅ NFT deployed to:", nft.address);

        // Deploy ERC20 Token
        console.log("\n🪙 Deploying ERC20 Token...");
        const MyToken = await ethers.getContractFactory("MyToken");
        const token = await MyToken.deploy();
        await token.deployed();
        console.log("✅ ERC20 Token deployed to:", token.address);

        // Deploy Price Feed Consumer (for testing, will use mock addresses)
        // In production, you would use real Chainlink price feed addresses:
        // ETH/USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306 (Goerli)
        // For production, replace these with actual Chainlink price feed addresses
        console.log("\n📊 Deploying Price Consumer contracts...");

        // For demonstration, we'll deploy with the deployer address as mock feeds
        // In production, use real Chainlink price feed addresses
        const ethUsdPriceFeed = deployer.address; // Replace with actual ETH/USD feed
        const erc20UsdPriceFeed = deployer.address; // Replace with actual ERC20/USD feed

        // Deploy Auction Market
        console.log("\n🏛️ Deploying Auction Market...");
        const AuctionMarket = await ethers.getContractFactory("AuctionMarket");
        const auctionMarket = await AuctionMarket.deploy(
            nft.address,
            token.address,
            ethUsdPriceFeed,
            erc20UsdPriceFeed
        );
        await auctionMarket.deployed();
        console.log("✅ Auction Market deployed to:", auctionMarket.address);

        // Setup auction contract in NFT
        console.log("\n🔗 Setting up auction contract in NFT...");
        await nft.setAuctionContract(auctionMarket.address);
        console.log("✅ Auction contract set in NFT");

        // Save deployment addresses
        const deploymentInfo = {
            network: network.name,
            deployer: deployer.address,
            deploymentTime: new Date().toISOString(),
            contracts: {
                NFT: nft.address,
                MyToken: token.address,
                AuctionMarket: auctionMarket.address,
                PriceFeeds: {
                    ethUsdPriceFeed: ethUsdPriceFeed,
                    erc20UsdPriceFeed: erc20UsdPriceFeed
                }
            },
            note: "Replace price feed addresses with actual Chainlink feeds for production"
        };

        const deploymentsDir = path.join(__dirname, "../deployments");
        if (!fs.existsSync(deploymentsDir)) {
            fs.mkdirSync(deploymentsDir);
        }

        const deploymentFile = path.join(deploymentsDir, `${network.name}.json`);
        fs.writeFileSync(
            deploymentFile,
            JSON.stringify(deploymentInfo, null, 2)
        );

        console.log("\n📋 Deployment Summary:");
        console.log("========================");
        console.log("Network:", network.name);
        console.log("NFT Contract:", nft.address);
        console.log("ERC20 Token:", token.address);
        console.log("Auction Market:", auctionMarket.address);
        console.log("Deployment info saved to:", deploymentFile);

        console.log("\n🎉 Deployment completed successfully!");
        console.log("\n⚠️ Important Notes:");
        console.log("- Replace mock price feed addresses with real Chainlink addresses for production");
        console.log("- Fund the Auction Market contract with some ETH for gas if needed");
        console.log("- Test the deployment thoroughly before production use");

        return {
            nft: nft.address,
            token: token.address,
            auctionMarket: auctionMarket.address,
            deploymentInfo: deploymentInfo
        };

    } catch (error) {
        console.error("❌ Deployment failed:", error);
        throw error;
    }
}

// Execute deployment
if (require.main === module) {
    main()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

module.exports = main;

