const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken Contract", function () {
    let MyToken;
    let token;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        MyToken = await ethers.getContractFactory("MyToken");
        [owner, addr1, addr2] = await ethers.getSigners();
        token = await MyToken.deploy();
        await token.deployed();
    });

    describe("Deployment", function () {
        it("Should have correct name and symbol", async function () {
            expect(await token.name()).to.equal("Auction Token");
            expect(await token.symbol()).to.equal("AUC");
        });

        it("Should mint initial supply to deployer", async function () {
            const expectedSupply = ethers.utils.parseUnits("1000000", 18);
            expect(await token.totalSupply()).to.equal(expectedSupply);
            expect(await token.balanceOf(owner.address)).to.equal(expectedSupply);
        });
    });

    describe("Minting", function () {
        it("Should allow owner to mint tokens", async function () {
            const amount = ethers.utils.parseUnits("100", 18);
            await token.mint(addr1.address, amount);

            expect(await token.balanceOf(addr1.address)).to.equal(amount);
        });

        it("Should not allow non-owner to mint tokens", async function () {
            const amount = ethers.utils.parseUnits("100", 18);
            await expect(
                token.connect(addr1).mint(addr2.address, amount)
            ).to.be.reverted;
        });
    });

    describe("Transfers", function () {
        it("Should transfer tokens between accounts", async function () {
            const amount = ethers.utils.parseUnits("100", 18);

            await token.transfer(addr1.address, amount);
            expect(await token.balanceOf(addr1.address)).to.equal(amount);

            const remainingBalance = ethers.utils.parseUnits("999900", 18);
            expect(await token.balanceOf(owner.address)).to.equal(remainingBalance);
        });
    });
});

