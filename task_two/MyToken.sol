// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MyToken
 * @dev 简单的 ERC20 代币合约实现
 */
contract MyToken {
    // 代币名称
    string public name;
    // 代币符号
    string public symbol;
    // 小数位数
    uint8 public decimals;
    // 总供应量
    uint256 public totalSupply;

    // 合约所有者
    address public owner;

    // 账户余额映射
    mapping(address => uint256) private _balances;

    // 授权额度映射 (spender => (owner => amount))
    mapping(address => mapping(address => uint256)) private _allowances;

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 构造函数
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
        totalSupply = 0;
    }

    /**
     * @dev 查询账户余额
     * @param account 账户地址
     * @return 账户余额
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev 转账代币
     * @param to 接收地址
     * @param amount 转账数量
     * @return 是否成功
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev 授权其他地址使用代币
     * @param spender 被授权地址
     * @param amount 授权数量
     * @return 是否成功
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev 查询授权额度
     * @param owner 所有者地址
     * @param spender 被授权地址
     * @return 授权额度
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev 从授权账户转账
     * @param from 转出账户
     * @param to 接收账户
     * @param amount 转账数量
     * @return 是否成功
     */
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _transfer(from, to, amount);

        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(from, msg.sender, currentAllowance - amount);

        return true;
    }

    /**
     * @dev 增发代币（仅合约所有者可调用）
     * @param to 接收地址
     * @param amount 增发数量
     */
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Only owner can mint tokens");

        totalSupply += amount;
        _balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev 内部转账函数
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= amount, "ERC20: transfer amount exceeds balance");

        _balances[from] -= amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    /**
     * @dev 内部授权函数
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
}

