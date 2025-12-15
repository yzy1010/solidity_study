# 作业3：编写一个讨饭合约 - 完成指南

## ✅ 任务完成情况

### 基础要求 ✅

1. **✅ 创建 BeggingContract 合约**
   - 合约名称：`BeggingContract.sol`
   - 位置：`/task_three/BeggingContract.sol`

2. **✅ 实现基础功能**
   - ✅ 使用 `mapping` 记录每个捐赠者的捐赠金额
   - ✅ `donate()` 函数允许用户向合约发送以太币
   - ✅ `withdraw()` 函数允许合约所有者提取所有资金
   - ✅ `getDonation()` 函数查询特定地址的捐赠金额
   - ✅ 使用 `payable` 修饰符和 `address.transfer` 实现支付和提款

3. **✅ 权限控制**
   - ✅ 使用 `onlyOwner` 修饰符限制 `withdraw` 函数
   - ✅ 使用 `onlyOwner` 修饰符限制 `setDonationTimeLimit` 函数

### 额外挑战 ✅

1. **✅ 捐赠事件**
   - ✅ `Donation` 事件记录每次捐赠的地址和金额
   - ✅ `Withdrawal` 事件记录提款信息
   - ✅ `TimeLimitSet` 事件记录时间限制设置

2. **✅ 捐赠排行榜**
   - ✅ `getTopDonors()` 函数显示捐赠金额最多的前3个地址
   - ✅ 使用冒泡排序算法按捐赠金额降序排列
   - ✅ 返回地址数组和金额数组的元组

3. **✅ 时间限制**
   - ✅ `setDonationTimeLimit()` 函数设置捐赠时间段
   - ✅ 在 `donate()` 函数中检查时间限制
   - ✅ 默认设置为永久开放捐赠

## 📁 文件结构

```
task_three/
├── BeggingContract.sol          # 主合约文件
├── test_BeggingContract.js      # 测试文件
├── deploy.js                    # 部署脚本
├── README.md                    # 项目文档
├── package.json                 # 项目配置
├── hardhat.config.js           # Hardhat 配置
└── HOMEWORK_COMPLETION_GUIDE.md # 本文件
```

## 🚀 部署和测试指南

### 1. 本地测试

```bash
# 安装依赖
npm install

# 运行测试
npm test

# 编译合约
npm run compile
```

### 2. 部署到测试网

#### 准备工作
1. 获取测试网 ETH（Goerli 或 Sepolia）
2. 获取 Infura 项目 ID
3. 准备钱包私钥

#### 配置部署
1. 编辑 `hardhat.config.js`
2. 替换 `YOUR_INFURA_PROJECT_ID` 为你的 Infura 项目 ID
3. 替换 `YOUR_PRIVATE_KEY` 为你的钱包私钥

#### 执行部署
```bash
# 部署到 Goerli
npm run deploy -- --network goerli

# 部署到 Sepolia
npm run deploy -- --network sepolia
```

### 3. 在 Remix IDE 中测试

1. **编译合约**
   - 打开 [Remix IDE](https://remix.ethereum.org/)
   - 创建新文件 `BeggingContract.sol`
   - 复制合约代码
   - 选择 Solidity 编译器版本 0.8.0+
   - 点击 "Compile"

2. **部署合约**
   - 选择 "Deploy & Run Transactions"
   - 环境选择 "JavaScript VM" 或 "Injected Web3"
   - 点击 "Deploy"

3. **测试功能**

   **捐赠测试**
   ```javascript
   // 设置捐赠金额（例如 1 ETH）
   // 在 "Value" 字段输入 1000000000000000000 (1 ETH in wei)
   // 点击 donate() 按钮
   ```

   **查询测试**
   ```javascript
   // 查询捐赠金额
   getDonation("0x...")

   // 获取排行榜
   getTopDonors()

   // 查询合约余额
   getContractBalance()
   ```

   **时间限制测试**
   ```javascript
   // 设置时间限制（使用时间戳）
   setDonationTimeLimit(1640995200, 1641081600)
   ```

   **提款测试**
   ```javascript
   // 只有合约所有者可以调用
   withdraw()
   ```

## 📋 功能验证清单

### 基础功能验证
- [ ] 合约可以成功部署
- [ ] 用户可以发送 ETH 进行捐赠
- [ ] 捐赠金额正确记录
- [ ] 多次捐赠金额正确累计
- [ ] 所有者可以提取资金
- [ ] 非所有者无法提取资金
- [ ] 可以查询特定地址的捐赠金额

### 高级功能验证
- [ ] 捐赠事件正确触发
- [ ] 排行榜正确显示前3名
- [ ] 时间限制功能正常工作
- [ ] Fallback 函数接受直接转账
- [ ] 所有错误情况正确处理

## 📝 提交内容

### 1. 合约代码
- 文件：`BeggingContract.sol`
- 包含所有基础功能和额外挑战功能

### 2. 合约地址
- 部署到测试网后的合约地址
- 示例：`0x1234567890123456789012345678901234567890`

### 3. 测试截图
- 在 Remix 或 Etherscan 上的测试截图
- 包括：
  - 合约部署成功截图
  - 捐赠功能测试截图
  - 排行榜功能测试截图
  - 提款功能测试截图

## 🎯 技术亮点

1. **安全性**
   - 使用 `onlyOwner` 修饰符保护关键函数
   - 输入验证防止无效操作
   - 使用 `transfer()` 防止重入攻击

2. **功能性**
   - 完整的捐赠管理系统
   - 实时排行榜功能
   - 灵活的时间限制设置

3. **用户体验**
   - 清晰的错误提示信息
   - 详细的事件记录
   - 便捷的查询功能

## 🔍 常见问题

### Q: 为什么使用 `transfer()` 而不是 `call()`？
A: `transfer()` 更安全，有固定的 gas 限制，可以防止重入攻击。

### Q: 排行榜排序算法效率如何？
A: 使用冒泡排序，对于少量数据（通常不超过100个捐赠者）效率足够。

### Q: 时间限制如何设置？
A: 使用 Unix 时间戳格式，可以通过在线工具转换日期为时间戳。

## 📚 参考资料

- [Solidity 官方文档](https://docs.soliditylang.org/)
- [Hardhat 文档](https://hardhat.org/)
- [Remix IDE 文档](https://remix-ide.readthedocs.io/)
- [Etherscan 验证指南](https://docs.etherscan.io/)

---

**祝你好运！如果遇到问题，可以参考 README.md 中的详细说明。**

