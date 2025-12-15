# MyToken - ERC20 代币合约

这是一个简单的 ERC20 代币合约实现，包含了标准的 ERC20 功能和额外的 mint 功能。

## 功能特性

### 标准 ERC20 功能
- `balanceOf(address account)` - 查询账户余额
- `transfer(address to, uint256 amount)` - 转账代币
- `approve(address spender, uint256 amount)` - 授权其他地址使用代币
- `transferFrom(address from, address to, uint256 amount)` - 从授权账户代扣转账
- `allowance(address owner, address spender)` - 查询授权额度

### 额外功能
- `mint(address to, uint256 amount)` - 增发代币（仅合约所有者可调用）
- `name()` - 获取代币名称
- `symbol()` - 获取代币符号
- `decimals()` - 获取小数位数
- `totalSupply()` - 获取总供应量

### 事件
- `Transfer(address indexed from, address indexed to, uint256 value)` - 转账事件
- `Approval(address indexed owner, address indexed spender, uint256 value)` - 授权事件

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

## 导入到钱包

1. 部署合约后，记下合约地址
2. 在 MetaMask 或其他钱包中：
   - 点击"添加代币"
   - 选择"自定义代币"
   - 输入合约地址
   - 代币符号会自动填充为 "MTK"
   - 小数位数会自动填充为 18

## 安全注意事项

- 请确保私钥安全，不要在公共场合暴露
- 在部署到主网前请充分测试
- mint 功能仅合约所有者可用，请妥善保管所有者账户

## 许可证

MIT License

