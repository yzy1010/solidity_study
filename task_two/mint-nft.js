const hre = require("hardhat");

async function main() {
    console.log("开始铸造NFT...");

    // 获取部署账户
    const [deployer] = await hre.ethers.getSigners();
    console.log("铸造账户:", deployer.address);
    console.log("账户余额:", (await deployer.getBalance()).toString());

    // NFT合约地址（需要替换为实际部署的合约地址）
    const contractAddress = "YOUR_NFT_CONTRACT_ADDRESS";

    // 接收NFT的地址（默认为部署者地址）
    const recipientAddress = deployer.address;

    // NFT元数据的IPFS链接（需要替换为实际的IPFS链接）
    const tokenURI = "https://gateway.pinata.cloud/ipfs/YOUR_METADATA_HASH";

    console.log("\n铸造参数:");
    console.log("合约地址:", contractAddress);
    console.log("接收地址:", recipientAddress);
    console.log("元数据URI:", tokenURI);

    // 连接到已部署的NFT合约
    const MyNFT = await hre.ethers.getContractFactory("MyNFT");
    const myNFT = await MyNFT.attach(contractAddress);

    console.log("\n正在铸造NFT...");

    // 铸造NFT
    const tx = await myNFT.mintNFT(recipientAddress, tokenURI);
    console.log("交易哈希:", tx.hash);

    // 等待交易确认
    const receipt = await tx.wait();
    console.log("交易已确认，区块号:", receipt.blockNumber);

    // 获取新铸造的tokenId（从事件中解析）
    const mintEvent = receipt.events?.find(e => e.event === 'NFTMinted');
    if (mintEvent) {
        const tokenId = mintEvent.args.tokenId.toString();
        console.log("\n=== 铸造成功 ===");
        console.log("新铸造的NFT Token ID:", tokenId);
        console.log("NFT所有者:", await myNFT.ownerOf(tokenId));
        console.log("NFT元数据URI:", await myNFT.tokenURI(tokenId));
        console.log("已铸造的NFT总数:", await myNFT.totalSupply());

        console.log("\n=== 查看NFT ===");
        console.log("1. 在OpenSea测试网查看:");
        console.log(`   https://testnets.opensea.io/assets/sepolia/${contractAddress}/${tokenId}`);
        console.log("2. 在Etherscan测试网查看交易:");
        console.log(`   https://sepolia.etherscan.io/tx/${tx.hash}`);
    } else {
        console.log("铸造成功，但无法解析tokenId");
        console.log("已铸造的NFT总数:", await myNFT.totalSupply());
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

