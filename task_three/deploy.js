const { ethers } = require("hardhat");

async function main() {
    console.log("开始部署 BeggingContract...");

    // 获取部署账户
    const [deployer] = await ethers.getSigners();
    console.log("部署账户:", deployer.address);
    console.log("账户余额:", (await deployer.getBalance()).toString());

    // 部署合约
    const BeggingContract = await ethers.getContractFactory("BeggingContract");
    const beggingContract = await BeggingContract.deploy();

    await beggingContract.deployed();

    console.log("BeggingContract 部署成功!");
    console.log("合约地址:", beggingContract.address);
    console.log("合约所有者:", await beggingContract.owner());

    // 验证合约
    console.log("\n合约验证:");
    console.log("- 捐赠开始时间:", (await beggingContract.donationStartTime()).toString());
    console.log("- 捐赠结束时间:", (await beggingContract.donationEndTime()).toString());
    console.log("- 合约余额:", (await beggingContract.getContractBalance()).toString());

    return beggingContract.address;
}

// 处理错误
main()
    .then((contractAddress) => {
        console.log("\n✅ 部署完成!");
        console.log("合约地址:", contractAddress);
        process.exit(0);
    })
    .catch((error) => {
        console.error("❌ 部署失败:", error);
        process.exit(1);
    });

