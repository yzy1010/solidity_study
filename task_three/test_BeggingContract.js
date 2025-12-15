const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BeggingContract", function () {
    let beggingContract;
    let owner;
    let addr1;
    let addr2;
    let addr3;

    beforeEach(async function () {
        // 获取测试账户
        [owner, addr1, addr2, addr3] = await ethers.getSigners();

        // 部署合约
        const BeggingContract = await ethers.getContractFactory("BeggingContract");
        beggingContract = await BeggingContract.deploy();
        await beggingContract.deployed();
    });

    describe("部署", function () {
        it("应该正确设置合约所有者", async function () {
            expect(await beggingContract.owner()).to.equal(owner.address);
        });

        it("应该设置默认的时间限制", async function () {
            const startTime = await beggingContract.donationStartTime();
            const endTime = await beggingContract.donationEndTime();
            expect(startTime).to.equal(0);
            expect(endTime).to.equal("115792089237316195423570985008687907853269984665640564039457584007913129639935"); // type(uint256).max
        });
    });

    describe("捐赠功能", function () {
        it("应该允许用户捐赠", async function () {
            const donationAmount = ethers.utils.parseEther("1.0");

            await beggingContract.connect(addr1).donate({ value: donationAmount });

            expect(await beggingContract.getDonation(addr1.address)).to.equal(donationAmount);
        });

        it("应该记录多个捐赠", async function () {
            const donation1 = ethers.utils.parseEther("1.0");
            const donation2 = ethers.utils.parseEther("0.5");

            await beggingContract.connect(addr1).donate({ value: donation1 });
            await beggingContract.connect(addr1).donate({ value: donation2 });

            expect(await beggingContract.getDonation(addr1.address)).to.equal(ethers.utils.parseEther("1.5"));
        });

        it("应该拒绝零金额捐赠", async function () {
            await expect(beggingContract.connect(addr1).donate({ value: 0 }))
                .to.be.revertedWith("Donation amount must be greater than 0");
        });

        it("应该通过fallback函数接受捐赠", async function () {
            const donationAmount = ethers.utils.parseEther("1.0");

            await owner.sendTransaction({
                to: beggingContract.address,
                value: donationAmount
            });

            expect(await beggingContract.getDonation(owner.address)).to.equal(donationAmount);
        });
    });

    describe("提款功能", function () {
        beforeEach(async function () {
            // 先进行一些捐赠
            await beggingContract.connect(addr1).donate({ value: ethers.utils.parseEther("1.0") });
            await beggingContract.connect(addr2).donate({ value: ethers.utils.parseEther("2.0") });
        });

        it("应该允许所有者提款", async function () {
            const initialBalance = await ethers.provider.getBalance(owner.address);

            await beggingContract.connect(owner).withdraw();

            const finalBalance = await ethers.provider.getBalance(owner.address);
            expect(finalBalance).to.be.gt(initialBalance);
        });

        it("应该拒绝非所有者提款", async function () {
            await expect(beggingContract.connect(addr1).withdraw())
                .to.be.revertedWith("Only owner can call this function");
        });
    });

    describe("排行榜功能", function () {
        beforeEach(async function () {
            // 进行不同金额的捐赠
            await beggingContract.connect(addr1).donate({ value: ethers.utils.parseEther("1.0") });
            await beggingContract.connect(addr2).donate({ value: ethers.utils.parseEther("3.0") });
            await beggingContract.connect(addr3).donate({ value: ethers.utils.parseEther("2.0") });
        });

        it("应该正确返回捐赠排行榜", async function () {
            const [topDonors, topAmounts] = await beggingContract.getTopDonors();

            expect(topDonors[0]).to.equal(addr2.address); // 最高捐赠者
            expect(topAmounts[0]).to.equal(ethers.utils.parseEther("3.0"));

            expect(topDonors[1]).to.equal(addr3.address); // 第二高捐赠者
            expect(topAmounts[1]).to.equal(ethers.utils.parseEther("2.0"));

            expect(topDonors[2]).to.equal(addr1.address); // 第三高捐赠者
            expect(topAmounts[2]).to.equal(ethers.utils.parseEther("1.0"));
        });
    });

    describe("时间限制功能", function () {
        it("应该允许所有者设置时间限制", async function () {
            const startTime = Math.floor(Date.now() / 1000) + 100; // 100秒后开始
            const endTime = startTime + 3600; // 1小时后结束

            await beggingContract.connect(owner).setDonationTimeLimit(startTime, endTime);

            expect(await beggingContract.donationStartTime()).to.equal(startTime);
            expect(await beggingContract.donationEndTime()).to.equal(endTime);
        });

        it("应该拒绝无效的时间设置", async function () {
            const startTime = Math.floor(Date.now() / 1000) + 100;
            const endTime = startTime - 50; // 结束时间早于开始时间

            await expect(beggingContract.connect(owner).setDonationTimeLimit(startTime, endTime))
                .to.be.revertedWith("Start time must be before end time");
        });
    });
});

