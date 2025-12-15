const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken", function () {
    let MyToken;
    let myToken;
    let owner;
    let addr1;
    let addr2;
    let addr3;

    beforeEach(async function () {
        // 获取测试账户
        [owner, addr1, addr2, addr3] = await ethers.getSigners();

        // 部署合约
        MyToken = await ethers.getContractFactory("MyToken");
        myToken = await MyToken.deploy("MyToken", "MTK", 18);
        await myToken.deployed();
    });

    describe("部署", function () {
        it("应该正确设置代币名称和符号", async function () {
            expect(await myToken.name()).to.equal("MyToken");
            expect(await myToken.symbol()).to.equal("MTK");
            expect(await myToken.decimals()).to.equal(18);
        });

        it("应该设置正确的合约所有者", async function () {
            expect(await myToken.owner()).to.equal(owner.address);
        });

        it("初始总供应量应该为0", async function () {
            expect(await myToken.totalSupply()).to.equal(0);
        });
    });

    describe("mint功能", function () {
        it("只有所有者可以mint代币", async function () {
            await expect(
                myToken.connect(addr1).mint(addr2.address, 1000)
            ).to.be.revertedWith("Only owner can mint tokens");
        });

        it("所有者可以mint代币", async function () {
            await myToken.mint(addr1.address, 1000);
            expect(await myToken.balanceOf(addr1.address)).to.equal(1000);
            expect(await myToken.totalSupply()).to.equal(1000);
        });

        it("mint应该触发Transfer事件", async function () {
            await expect(myToken.mint(addr1.address, 1000))
                .to.emit(myToken, "Transfer")
                .withArgs(ethers.constants.AddressZero, addr1.address, 1000);
        });
    });

    describe("转账功能", function () {
        beforeEach(async function () {
            // 先mint一些代币给测试账户
            await myToken.mint(addr1.address, 1000);
        });

        it("可以正常转账", async function () {
            await myToken.connect(addr1).transfer(addr2.address, 500);
            expect(await myToken.balanceOf(addr1.address)).to.equal(500);
            expect(await myToken.balanceOf(addr2.address)).to.equal(500);
        });

        it("转账应该触发Transfer事件", async function () {
            await expect(myToken.connect(addr1).transfer(addr2.address, 500))
                .to.emit(myToken, "Transfer")
                .withArgs(addr1.address, addr2.address, 500);
        });

        it("余额不足时转账应该失败", async function () {
            await expect(
                myToken.connect(addr1).transfer(addr2.address, 2000)
            ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
        });

        it("不能转账到零地址", async function () {
            await expect(
                myToken.connect(addr1).transfer(ethers.constants.AddressZero, 100)
            ).to.be.revertedWith("ERC20: transfer to the zero address");
        });
    });

    describe("授权功能", function () {
        beforeEach(async function () {
            await myToken.mint(addr1.address, 1000);
        });

        it("可以设置授权额度", async function () {
            await myToken.connect(addr1).approve(addr2.address, 500);
            expect(await myToken.allowance(addr1.address, addr2.address)).to.equal(500);
        });

        it("授权应该触发Approval事件", async function () {
            await expect(myToken.connect(addr1).approve(addr2.address, 500))
                .to.emit(myToken, "Approval")
                .withArgs(addr1.address, addr2.address, 500);
        });

        it("不能授权零地址", async function () {
            await expect(
                myToken.connect(addr1).approve(ethers.constants.AddressZero, 100)
            ).to.be.revertedWith("ERC20: approve to the zero address");
        });
    });

    describe("transferFrom功能", function () {
        beforeEach(async function () {
            await myToken.mint(addr1.address, 1000);
            await myToken.connect(addr1).approve(addr2.address, 500);
        });

        it("被授权地址可以代扣转账", async function () {
            await myToken.connect(addr2).transferFrom(addr1.address, addr3.address, 300);
            expect(await myToken.balanceOf(addr1.address)).to.equal(700);
            expect(await myToken.balanceOf(addr3.address)).to.equal(300);
            expect(await myToken.allowance(addr1.address, addr2.address)).to.equal(200);
        });

        it("授权额度不足时应该失败", async function () {
            await expect(
                myToken.connect(addr2).transferFrom(addr1.address, addr3.address, 600)
            ).to.be.revertedWith("ERC20: transfer amount exceeds allowance");
        });

        it("transferFrom应该触发Transfer事件", async function () {
            await expect(myToken.connect(addr2).transferFrom(addr1.address, addr3.address, 300))
                .to.emit(myToken, "Transfer")
                .withArgs(addr1.address, addr3.address, 300);
        });
    });
});

