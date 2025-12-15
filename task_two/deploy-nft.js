const hre = require("hardhat");

async function main() {
    console.log("开始部署 MyNFT 合约...");

    // 获取部署账户
    const [deployer] = await hre.ethers.getSigners();
    console.log("部署账户:", deployer.address);
    console.log("账户余额:", (await deployer.getBalance()).toString());

    // 部署NFT合约
    const MyNFT = await hre.ethers.getContractFactory("MyNFT");
    const myNFT = await MyNFT.deploy("我的NFT收藏", "MNFT");

    await myNFT.deployed();

    console.log("MyNFT 合约已部署到地址:", myNFT.address);
    console.log("NFT名称:", await myNFT.name());
    console.log("NFT符号:", await myNFT.symbol());
    console.log("合约所有者:", await myNFT.owner());
    console.log("下一个可用的Token ID:", await myNFT.getNextTokenId());
    console.log("已铸造的NFT总数:", await myNFT.totalSupply());

    console.log("\n=== 部署完成 ===");
    console.log("请保存以下信息:");
    console.log("合约地址:", myNFT.address);
    console.log("部署者地址:", deployer.address);
    console.log("\n接下来你可以:");
    console.log("1. 使用 mint-nft.js 脚本铸造NFT");
    console.log("2. 在OpenSea测试网查看你的NFT");
    console.log("3. 将合约地址导入到钱包中");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

