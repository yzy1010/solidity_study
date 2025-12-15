const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyNFT", function () {
    let MyNFT;
    let myNFT;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        // 获取测试账户
        [owner, addr1, addr2] = await ethers.getSigners();

        // 部署合约
        MyNFT = await ethers.getContractFactory("MyNFT");
        myNFT = await MyNFT.deploy("Test NFT", "TNFT");
        await myNFT.deployed();
    });

    describe("部署", function () {
        it("应该正确设置名称和符号", async function () {
            expect(await myNFT.name()).to.equal("Test NFT");
            expect(await myNFT.symbol()).to.equal("TNFT");
        });

        it("应该设置正确的合约所有者", async function () {
            expect(await myNFT.owner()).to.equal(owner.address);
        });

        it("初始状态下没有NFT", async function () {
            expect(await myNFT.totalSupply()).to.equal(0);
            expect(await myNFT.getNextTokenId()).to.equal(1);
        });
    });

    describe("铸造NFT", function () {
        it("只有所有者可以铸造NFT", async function () {
            const tokenURI = "https://example.com/metadata/1";

            // 非所有者尝试铸造应该失败
            await expect(
                myNFT.connect(addr1).mintNFT(addr1.address, tokenURI)
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("所有者可以成功铸造NFT", async function () {
            const tokenURI = "https://example.com/metadata/1";

            // 铸造NFT
            const tx = await myNFT.mintNFT(addr1.address, tokenURI);
            const receipt = await tx.wait();

            // 检查事件
            const event = receipt.events?.find(e => e.event === 'NFTMinted');
            expect(event.args.recipient).to.equal(addr1.address);
            expect(event.args.tokenURI).to.equal(tokenURI);

            // 检查tokenId
            const tokenId = event.args.tokenId;
            expect(tokenId).to.equal(1);

            // 检查NFT信息
            expect(await myNFT.ownerOf(tokenId)).to.equal(addr1.address);
            expect(await myNFT.tokenURI(tokenId)).to.equal(tokenURI);
            expect(await myNFT.balanceOf(addr1.address)).to.equal(1);
            expect(await myNFT.totalSupply()).to.equal(1);
        });

        it("可以铸造多个NFT", async function () {
            const tokenURI1 = "https://example.com/metadata/1";
            const tokenURI2 = "https://example.com/metadata/2";

            // 铸造第一个NFT
            await myNFT.mintNFT(addr1.address, tokenURI1);

            // 铸造第二个NFT
            await myNFT.mintNFT(addr2.address, tokenURI2);

            // 检查状态
            expect(await myNFT.totalSupply()).to.equal(2);
            expect(await myNFT.getNextTokenId()).to.equal(3);
            expect(await myNFT.balanceOf(addr1.address)).to.equal(1);
            expect(await myNFT.balanceOf(addr2.address)).to.equal(1);
        });
    });

    describe("转移NFT", function () {
        beforeEach(async function () {
            // 先铸造一个NFT
            await myNFT.mintNFT(addr1.address, "https://example.com/metadata/1");
        });

        it("所有者可以转移NFT", async function () {
            // addr1转移NFT给addr2
            await myNFT.connect(addr1).transferFrom(
                addr1.address,
                addr2.address,
                1
            );

            // 检查所有权
            expect(await myNFT.ownerOf(1)).to.equal(addr2.address);
            expect(await myNFT.balanceOf(addr1.address)).to.equal(0);
            expect(await myNFT.balanceOf(addr2.address)).to.equal(1);
        });

        it("非所有者不能转移NFT", async function () {
            // addr2尝试转移addr1的NFT应该失败
            await expect(
                myNFT.connect(addr2).transferFrom(
                    addr1.address,
                    addr2.address,
                    1
                )
            ).to.be.reverted;
        });
    });

    describe("销毁NFT", function () {
        beforeEach(async function () {
            // 先铸造一个NFT
            await myNFT.mintNFT(addr1.address, "https://example.com/metadata/1");
        });

        it("只有所有者可以销毁NFT", async function () {
            // 非所有者尝试销毁应该失败
            await expect(
                myNFT.connect(addr1).burn(1)
            ).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("所有者可以成功销毁NFT", async function () {
            // 所有者销毁NFT
            await myNFT.burn(1);

            // 检查NFT是否被销毁
            await expect(myNFT.ownerOf(1)).to.be.reverted;
            expect(await myNFT.totalSupply()).to.equal(0);
            expect(await myNFT.balanceOf(addr1.address)).to.equal(0);
        });
    });
});

