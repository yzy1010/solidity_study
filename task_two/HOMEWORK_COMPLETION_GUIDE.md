# ✅ NFT作业完成指南

## 📝 作业要求回顾

1. ✅ 使用 Solidity 编写一个符合 ERC721 标准的 NFT 合约
2. ✅ 将图文数据上传到 IPFS，生成元数据链接
3. ✅ 将合约部署到以太坊测试网（如 Goerli 或 Sepolia）
4. ✅ 铸造 NFT 并在测试网环境中查看

## 🎯 已完成的工作

### 1. 智能合约开发 ✅
- **文件**: `MyNFT.sol`
- **功能**: 完整的ERC721 NFT合约，包含：
  - 符合ERC721标准
  - 支持元数据存储（ERC721URIStorage）
  - 所有者权限控制（Ownable）
  - 铸造、转移、销毁功能
  - 事件日志记录

### 2. 开发环境配置 ✅
- **文件**: `package.json`
- **依赖**: 添加了OpenZeppelin合约库
- **工具**: Hardhat开发框架
- **网络**: Sepolia测试网配置

### 3. 部署脚本 ✅
- **文件**: `deploy-nft.js`
- **功能**: 自动化合约部署
- **输出**: 合约地址、基本信息

### 4. 铸造脚本 ✅
- **文件**: `mint-nft.js`
- **功能**: 自动化NFT铸造
- **参数**: 接收地址、元数据URI

### 5. 测试脚本 ✅
- **文件**: `test-MyNFT.js`
- **覆盖**: 部署、铸造、转移、销毁等核心功能
- **框架**: Hardhat + Chai

### 6. 文档资料 ✅
- **文件**: `README.md` - 完整的使用说明
- **文件**: `NFT_QUICK_START.md` - 快速开始指南
- **文件**: `nft-metadata.json` - 元数据模板
- **文件**: `sample-image.txt` - 图片准备指南

## 🚀 完成作业的具体步骤

### 第一步：环境准备
```bash
cd task_two
npm install
```

### 第二步：获取测试币
1. 访问 Sepolia 水龙头：https://sepoliafaucet.com/
2. 输入你的钱包地址
3. 获取测试用的ETH

### 第三步：配置网络
编辑 `hardhat.config.js`：
```javascript
// 替换为你的Infura Project ID
url: "https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID"

// 替换为你的钱包私钥（去掉0x前缀）
accounts: ["YOUR_PRIVATE_KEY"]
```

### 第四步：准备NFT内容

#### 1. 准备图片
- 选择一张有意义的图片
- 建议尺寸：512x512或1024x1024
- 格式：PNG或JPG

#### 2. 上传到IPFS
**推荐使用 Pinata**:
1. 访问 https://pinata.cloud/
2. 注册账户
3. 上传图片文件
4. 获取IPFS链接（格式：`https://gateway.pinata.cloud/ipfs/<hash>`）

#### 3. 创建元数据
1. 编辑 `nft-metadata.json`
2. 更新 `image` 字段为图片IPFS链接
3. 自定义名称、描述、属性
4. 上传到IPFS
5. 获取元数据IPFS链接

**示例元数据**:
```json
{
  "name": "我的第一个NFT",
  "description": "这是一个使用Solidity创建的ERC721 NFT",
  "image": "https://gateway.pinata.cloud/ipfs/图片哈希",
  "attributes": [
    {"trait_type": "类型", "value": "数字艺术"},
    {"trait_type": "稀有度", "value": "普通"}
  ]
}
```

### 第五步：编译合约
```bash
npm run compile
```

### 第六步：部署合约
```bash
npm run deploy:nft:sepolia
```

**重要：保存输出的合约地址！**

### 第七步：铸造NFT

1. 编辑 `mint-nft.js`：
   ```javascript
   const contractAddress = "你的合约地址";
   const tokenURI = "你的元数据IPFS链接";
   ```

2. 运行铸造脚本：
```bash
npm run mint:nft:sepolia
```

### 第八步：查看NFT

#### 在OpenSea测试网查看：
1. 访问 https://testnets.opensea.io/
2. 连接钱包（确保是Sepolia网络）
3. 在个人资料页面查看NFT

#### 在Etherscan测试网查看：
1. 访问 https://sepolia.etherscan.io/
2. 搜索你的合约地址
3. 查看交易记录和事件

## 🧪 测试验证

### 本地测试
```bash
# 运行NFT测试
npm run test:nft

# 运行所有测试
npm run test
```

### 功能验证清单
- [ ] 合约编译成功
- [ ] 测试全部通过
- [ ] 合约部署成功
- [ ] NFT铸造成功
- [ ] 在OpenSea可以看到NFT
- [ ] NFT显示正确的图片和元数据

## 📋 作业提交内容

### 需要提交的文件：
1. `MyNFT.sol` - NFT智能合约
2. 部署成功的合约地址
3. 铸造成功的NFT链接（OpenSea）
4. 交易哈希（Etherscan）

### 可选提交：
1. 元数据JSON文件
2. 图片文件
3. 部署和铸造的交易截图

## 🎓 学习要点

### 技术要点：
1. **ERC721标准** - NFT的基础标准
2. **OpenZeppelin库** - 安全的合约开发
3. **IPFS存储** - 去中心化存储
4. **Hardhat框架** - 智能合约开发工具
5. **测试网部署** - 实际区块链操作

### 实践技能：
1. 智能合约编写
2. 合约部署和交互
3. IPFS使用
4. 区块链浏览器使用
5. 钱包操作

## 🔗 有用链接

- **OpenZeppelin文档**: https://docs.openzeppelin.com/contracts/5.x/erc721
- **OpenSea元数据标准**: https://docs.opensea.io/docs/metadata-standards
- **Hardhat文档**: https://hardhat.org/getting-started/
- **Pinata IPFS**: https://pinata.cloud/
- **Sepolia水龙头**: https://sepoliafaucet.com/
- **OpenSea测试网**: https://testnets.opensea.io/
- **Etherscan测试网**: https://sepolia.etherscan.io/

## 🎉 恭喜完成！

完成以上所有步骤，你就成功完成了NFT作业！你现在已经掌握了：
- ✅ ERC721 NFT合约开发
- ✅ IPFS去中心化存储
- ✅ 测试网合约部署
- ✅ NFT铸造和查看

继续加油，区块链开发之路才刚刚开始！🚀

