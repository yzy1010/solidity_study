# NFT作业快速开始指南

## 🎯 作业目标
在以太坊测试网上发行一个图文并茂的NFT

## 📋 完成步骤

### 第一步：环境准备
```bash
cd task_two
npm install
```

### 第二步：配置网络
编辑 `hardhat.config.js` 文件：
- 替换 `YOUR_INFURA_PROJECT_ID` 为你的 Infura Project ID
- 替换 `YOUR_PRIVATE_KEY` 为你的钱包私钥

### 第三步：准备NFT内容

#### 1. 准备图片
- 选择一张图片（建议尺寸：512x512或1024x1024）
- 格式：PNG或JPG

#### 2. 上传到IPFS
推荐使用 Pinata (https://pinata.cloud/)：
1. 注册账户
2. 上传图片文件
3. 获取图片IPFS链接（格式：`https://gateway.pinata.cloud/ipfs/<hash>`）

#### 3. 创建元数据
1. 编辑 `nft-metadata.json` 文件
2. 更新 `image` 字段为图片IPFS链接
3. 自定义名称、描述、属性等
4. 上传JSON文件到IPFS
5. 获取元数据IPFS链接

### 第四步：部署合约
```bash
# 编译合约
npm run compile

# 部署到Sepolia测试网
npx hardhat run deploy-nft.js --network sepolia
```

**重要：保存输出的合约地址！**

### 第五步：铸造NFT

1. 编辑 `mint-nft.js` 文件：
   - 替换 `YOUR_NFT_CONTRACT_ADDRESS` 为实际合约地址
   - 替换 `YOUR_METADATA_HASH` 为元数据IPFS链接

2. 运行铸造脚本：
```bash
npx hardhat run mint-nft.js --network sepolia
```

### 第六步：查看NFT

1. **OpenSea测试网**：https://testnets.opensea.io/
   - 连接钱包（Sepolia网络）
   - 查看你的NFT

2. **Etherscan测试网**：https://sepolia.etherscan.io/
   - 搜索合约地址
   - 查看交易记录

## 🔧 常见问题

### Q: 如何获取测试币？
A: 访问 Sepolia 水龙头：
- https://sepoliafaucet.com/
- https://faucet.sepolia.dev/

### Q: IPFS链接格式是什么？
A: 格式应该是：`https://gateway.pinata.cloud/ipfs/<hash>`

### Q: 如何查看NFT是否铸造成功？
A:
1. 在OpenSea测试网查看
2. 在Etherscan查看交易状态
3. 检查mint-nft.js脚本的输出

## 📁 文件说明

- `MyNFT.sol` - NFT智能合约
- `deploy-nft.js` - 合约部署脚本
- `mint-nft.js` - NFT铸造脚本
- `nft-metadata.json` - NFT元数据模板
- `sample-image.txt` - 图片准备指南

## 🎓 学习资源

- OpenZeppelin ERC721文档：https://docs.openzeppelin.com/contracts/5.x/erc721
- OpenSea元数据标准：https://docs.opensea.io/docs/metadata-standards
- Hardhat文档：https://hardhat.org/getting-started/

## ✅ 完成检查清单

- [ ] 安装了所有依赖
- [ ] 配置了Infura和私钥
- [ ] 准备了图片并上传到IPFS
- [ ] 创建了元数据JSON并上传到IPFS
- [ ] 成功部署了NFT合约
- [ ] 成功铸造了NFT
- [ ] 在OpenSea测试网查看了NFT

完成以上步骤，你的NFT作业就完成了！🎉

