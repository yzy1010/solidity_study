const hre = require("hardhat");

async function main() {
    console.log("开始部署 MyToken 合约...");

    // 获取部署账户
    const [deployer] = await hre.ethers.getSigners();
    console.log("部署账户:", deployer.address);
    console.log("账户余额:", (await deployer.getBalance()).toString());

    // 部署合约
    const MyToken = await hre.ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy("MyToken", "MTK", 18);

    await myToken.deployed();

    console.log("MyToken 合约已部署到地址:", myToken.address);
    console.log("代币名称:", await myToken.name());
    console.log("代币符号:", await myToken.symbol());
    console.log("小数位数:", await myToken.decimals());
    console.log("合约所有者:", await myToken.owner());

    // 给部署者mint一些代币用于测试
    const mintAmount = hre.ethers.utils.parseEther("1000"); // 1000 tokens
    await myToken.mint(deployer.address, mintAmount);
    console.log(`已给部署者mint ${hre.ethers.utils.formatEther(mintAmount)} MTK代币`);
    console.log("部署者余额:", hre.ethers.utils.formatEther(await myToken.balanceOf(deployer.address)));
    console.log("总供应量:", hre.ethers.utils.formatEther(await myToken.totalSupply()));
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

