# 🚀 NFT作业快速开始

欢迎来到NFT作业项目！这里有一份完整的指南，帮助你成功在以太坊测试网上发行一个图文并茂的NFT。

## 📋 项目概览

这个项目包含了：
- ✅ **MyNFT.sol** - 符合ERC721标准的NFT智能合约
- ✅ **完整的开发工具链** - Hardhat + OpenZeppelin
- ✅ **详细的文档指南** - 从入门到完成
- ✅ **测试脚本** - 确保合约功能正常

## 🎯 作业目标

1. 编写符合ERC721标准的NFT合约 ✅
2. 将图文数据上传到IPFS 📝
3. 将合约部署到以太坊测试网 📝
4. 铸造NFT并在测试网查看 📝

## 🚀 快速开始（6步完成）

### 第1步：准备工作
```bash
cd task_two
npm install
```

### 第2步：获取测试币
访问 https://sepoliafaucet.com/ 获取Sepolia测试网的ETH

### 第3步：配置网络
编辑 `hardhat.config.js`，填入你的：
- Infura Project ID
- 钱包私钥

### 第4步：准备NFT内容
1. 选择一张图片
2. 上传到IPFS（推荐Pinata）
3. 编辑 `nft-metadata.json`
4. 上传元数据到IPFS

### 第5步：部署和铸造
```bash
# 编译合约
npm run compile

# 部署合约
npm run deploy:nft:sepolia

# 铸造NFT（先编辑mint-nft.js）
npm run mint:nft:sepolia
```

### 第6步：查看NFT
- OpenSea测试网：https://testnets.opensea.io/
- Etherscan测试网：https://sepolia.etherscan.io/

## 📚 详细指南

### 📖 阅读顺序建议

1. **快速了解** → `NFT_QUICK_START.md`
2. **详细学习** → `README.md`
3. **完成作业** → `HOMEWORK_COMPLETION_GUIDE.md`
4. **了解项目** → `PROJECT_SUMMARY.md`

### 🎯 核心文件

| 文件 | 作用 | 重要性 |
|------|------|--------|
| `MyNFT.sol` | NFT智能合约 | ⭐⭐⭐⭐⭐ |
| `deploy-nft.js` | 部署脚本 | ⭐⭐⭐⭐⭐ |
| `mint-nft.js` | 铸造脚本 | ⭐⭐⭐⭐⭐ |
| `nft-metadata.json` | 元数据模板 | ⭐⭐⭐⭐ |
| `README.md` | 完整文档 | ⭐⭐⭐⭐⭐ |

## 🔧 常用命令

```bash
# 安装依赖
npm install

# 编译合约
npm run compile

# 运行测试
npm run test:nft

# 部署合约
npm run deploy:nft:sepolia

# 铸造NFT
npm run mint:nft:sepolia
```

## 🎓 学习资源

### 必学内容
- **ERC721标准**: NFT的基础标准
- **OpenZeppelin**: 安全的合约开发库
- **IPFS**: 去中心化存储
- **Hardhat**: 智能合约开发框架

### 推荐链接
- [OpenZeppelin文档](https://docs.openzeppelin.com/contracts/5.x/erc721)
- [OpenSea元数据标准](https://docs.opensea.io/docs/metadata-standards)
- [Hardhat文档](https://hardhat.org/getting-started/)
- [Pinata IPFS](https://pinata.cloud/)

## ❓ 常见问题

### Q: 如何获取测试币？
A: 访问Sepolia水龙头：https://sepoliafaucet.com/

### Q: IPFS是什么？
A: 去中心化存储网络，用于存储NFT的图片和元数据

### Q: 为什么选择Sepolia测试网？
A: Sepolia是稳定的以太坊测试网，适合开发和测试

### Q: 铸造NFT需要什么？
A: 需要：1）部署的合约地址 2）元数据的IPFS链接 3）足够的测试币支付gas费

## 🎯 成功标志

完成以下步骤即表示作业成功：
- [ ] 合约编译成功
- [ ] 合约部署成功
- [ ] NFT铸造成功
- [ ] 在OpenSea测试网看到NFT
- [ ] NFT显示正确的图片和描述

## 🚨 重要提醒

1. **私钥安全**：不要在公共场合暴露私钥
2. **测试充分**：在主网部署前请充分测试
3. **IPFS永久**：确保IPFS上的文件是永久存储的
4. **Gas费用**：确保钱包有足够的测试币支付交易费用

## 🎉 完成奖励

成功完成作业后，你将掌握：
- ✅ 智能合约开发
- ✅ 区块链网络交互
- ✅ 去中心化存储
- ✅ NFT发行流程

## 📞 需要帮助？

如果遇到问题，可以：
1. 查看详细的文档文件
2. 运行测试脚本检查合约
3. 参考学习资源链接
4. 检查常见问题和提醒

---

**开始你的NFT之旅吧！** 🚀
**项目位置**: `/Users/yezhiyi/code2/solidity_study/task_two/`
**预计完成时间**: 2-4小时
**难度等级**: 中级

祝你好运！🌟

