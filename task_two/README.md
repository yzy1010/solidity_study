# MyToken & MyNFT - ERC20代币和ERC721 NFT合约

这个项目包含了两个智能合约：
1. **MyToken** - 一个简单的ERC20代币合约实现
2. **MyNFT** - 一个符合ERC721标准的NFT合约，支持铸造和元数据

## 功能特性

### MyToken (ERC20) 功能

#### 标准 ERC20 功能
- `balanceOf(address account)` - 查询账户余额
- `transfer(address to, uint256 amount)` - 转账代币
- `approve(address spender, uint256 amount)` - 授权其他地址使用代币
- `transferFrom(address from, address to, uint256 amount)` - 从授权账户代扣转账
- `allowance(address owner, address spender)` - 查询授权额度

#### 额外功能
- `mint(address to, uint256 amount)` - 增发代币（仅合约所有者可调用）
- `name()` - 获取代币名称
- `symbol()` - 获取代币符号
- `decimals()` - 获取小数位数
- `totalSupply()` - 获取总供应量

#### 事件
- `Transfer(address indexed from, address indexed to, uint256 value)` - 转账事件
- `Approval(address indexed owner, address indexed spender, uint256 value)` - 授权事件

### MyNFT (ERC721) 功能

#### 标准 ERC721 功能
- `balanceOf(address owner)` - 查询地址拥有的NFT数量
- `ownerOf(uint256 tokenId)` - 查询NFT的所有者
- `transferFrom(address from, address to, uint256 tokenId)` - 转移NFT
- `approve(address to, uint256 tokenId)` - 授权其他地址操作NFT
- `getApproved(uint256 tokenId)` - 查询NFT的授权地址
- `setApprovalForAll(address operator, bool approved)` - 设置操作权限
- `isApprovedForAll(address owner, address operator)` - 查询操作权限

#### NFT特定功能
- `mintNFT(address recipient, string tokenURI)` - 铸造NFT（仅合约所有者可调用）
- `tokenURI(uint256 tokenId)` - 获取NFT的元数据URI
- `getNextTokenId()` - 获取下一个可用的tokenId
- `totalSupply()` - 获取已铸造的NFT总数
- `burn(uint256 tokenId)` - 销毁NFT（仅合约所有者可调用）

#### 事件
- `NFTMinted(address indexed recipient, uint256 indexed tokenId, string tokenURI)` - NFT铸造事件
- `Transfer(address indexed from, address indexed to, uint256 indexed tokenId)` - NFT转移事件
- `Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)` - NFT授权事件
- `ApprovalForAll(address indexed owner, address indexed operator, bool approved)` - 操作权限事件

## 部署说明

### 1. 安装依赖
```bash
cd task_two
npm install
```

### 2. 配置网络
编辑 `hardhat.config.js` 文件：
- 替换 `YOUR_INFURA_PROJECT_ID` 为你的 Infura Project ID
- 替换 `YOUR_PRIVATE_KEY` 为你的钱包私钥

### 3. 编译合约
```bash
npm run compile
```

### 4. 测试合约
```bash
npm run test
```

### 5. 部署到本地网络
```bash
npx hardhat node  # 启动本地节点
npm run deploy    # 部署到本地网络
```

### 6. 部署到 Sepolia 测试网
```bash
npm run deploy:sepolia
```

## MyNFT 使用说明

### 1. 安装依赖
```bash
cd task_two
npm install
```

### 2. 准备NFT元数据

#### 准备图片
1. 准备一张图片（PNG、JPG等格式）
2. 将图片上传到IPFS服务（如Pinata、Infura IPFS等）
3. 获取图片的IPFS链接

#### 创建元数据JSON文件
1. 编辑 `nft-metadata.json` 文件
2. 更新 `image` 字段为图片的IPFS链接
3. 自定义其他属性（名称、描述、特性等）
4. 将JSON文件上传到IPFS
5. 获取元数据JSON文件的IPFS链接

### 3. 编译合约
```bash
npm run compile
```

### 4. 部署NFT合约到本地网络
```bash
npx hardhat node  # 启动本地节点
npx hardhat run deploy-nft.js  # 部署NFT合约
```

### 5. 部署NFT合约到 Sepolia 测试网
```bash
npx hardhat run deploy-nft.js --network sepolia
```

### 6. 铸造NFT

编辑 `mint-nft.js` 文件：
- 替换 `YOUR_NFT_CONTRACT_ADDRESS` 为实际部署的合约地址
- 替换 `YOUR_METADATA_HASH` 为元数据JSON文件的IPFS链接

然后运行：
```bash
npx hardhat run mint-nft.js --network sepolia
```

### 7. 查看NFT

1. **OpenSea测试网**: https://testnets.opensea.io/
   - 连接你的钱包
   - 查看你拥有的NFT

2. **Etherscan测试网**: https://sepolia.etherscan.io/
   - 搜索你的合约地址
   - 查看交易记录

## 合约使用方法

### 基本转账
```javascript
// 查询余额
const balance = await myToken.balanceOf(userAddress);

// 转账
await myToken.transfer(recipientAddress, amount);
```

### 授权和代扣转账
```javascript
// 授权
await myToken.approve(spenderAddress, amount);

// 查询授权额度
const allowance = await myToken.allowance(ownerAddress, spenderAddress);

// 代扣转账
await myToken.transferFrom(ownerAddress, recipientAddress, amount);
```

### 增发代币（仅合约所有者）
```javascript
await myToken.mint(recipientAddress, amount);
```

## MyNFT 合约使用方法

### 铸造NFT（仅合约所有者）
```javascript
// 铸造NFT
const tokenId = await myNFT.mintNFT(recipientAddress, "https://gateway.pinata.cloud/ipfs/metadata-hash");
console.log("新铸造的NFT Token ID:", tokenId.toString());
```

### 查询NFT信息
```javascript
// 查询地址拥有的NFT数量
const balance = await myNFT.balanceOf(userAddress);

// 查询NFT的所有者
const owner = await myNFT.ownerOf(tokenId);

// 查询NFT的元数据URI
const tokenURI = await myNFT.tokenURI(tokenId);

// 查询下一个可用的tokenId
const nextTokenId = await myNFT.getNextTokenId();

// 查询已铸造的NFT总数
const totalSupply = await myNFT.totalSupply();
```

### 转移NFT
```javascript
// 转移NFT
await myNFT.transferFrom(fromAddress, toAddress, tokenId);

// 或者使用安全转移
await myNFT.safeTransferFrom(fromAddress, toAddress, tokenId);
```

### 授权操作
```javascript
// 授权单个NFT
await myNFT.approve(operatorAddress, tokenId);

// 查询授权地址
const approved = await myNFT.getApproved(tokenId);

// 设置操作权限
await myNFT.setApprovalForAll(operatorAddress, true);

// 查询操作权限
const isApproved = await myNFT.isApprovedForAll(ownerAddress, operatorAddress);
```

### 销毁NFT（仅合约所有者）
```javascript
await myNFT.burn(tokenId);
```

## 导入到钱包

1. 部署合约后，记下合约地址
2. 在 MetaMask 或其他钱包中：
   - 点击"添加代币"
   - 选择"自定义代币"
   - 输入合约地址
   - 代币符号会自动填充为 "MTK"
   - 小数位数会自动填充为 18

## 安全注意事项

### MyToken (ERC20) 安全注意事项
- 请确保私钥安全，不要在公共场合暴露
- 在部署到主网前请充分测试
- mint 功能仅合约所有者可用，请妥善保管所有者账户

### MyNFT (ERC721) 安全注意事项
- NFT合约的mintNFT功能仅合约所有者可用，请妥善保管所有者账户
- 在铸造NFT前，请确保元数据URI是正确的IPFS链接
- 一旦NFT被铸造，其元数据URI将无法更改
- 在部署到主网前请充分测试
- 请确保IPFS上的元数据和图片文件是永久存储的

## IPFS使用指南

### 推荐的IPFS服务
1. **Pinata** (https://pinata.cloud/)
   - 提供免费套餐
   - 易于使用的Web界面
   - 支持固定服务

2. **Infura IPFS** (https://infura.io/)
   - 集成在Infura服务中
   - 适合开发者使用

3. **NFT.Storage** (https://nft.storage/)
   - 专门为NFT设计
   - 免费存储NFT数据

### IPFS上传步骤
1. 注册IPFS服务账户
2. 上传图片文件，获取图片IPFS链接
3. 创建并编辑元数据JSON文件
4. 上传元数据JSON文件，获取元数据IPFS链接
5. 使用元数据IPFS链接铸造NFT

## 测试网查看指南

### OpenSea测试网
1. 访问 https://testnets.opensea.io/
2. 连接你的钱包（确保连接到Sepolia测试网）
3. 在个人资料页面查看你拥有的NFT
4. 可以查看NFT的详细信息、图片和属性

### Etherscan测试网
1. 访问 https://sepolia.etherscan.io/
2. 搜索你的NFT合约地址
3. 查看合约详情、交易记录和事件日志
4. 可以验证合约代码和查看内部交易

## 许可证

MIT License

