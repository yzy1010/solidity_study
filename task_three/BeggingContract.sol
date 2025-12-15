// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BeggingContract
 * @dev 一个简单的讨饭合约，允许用户捐赠以太币
 */
contract BeggingContract {
    // 合约所有者
    address public owner;

    // 记录每个地址的捐赠金额
    mapping(address => uint256) public donations;

    // 记录所有捐赠者地址
    address[] public donors;

    // 捐赠开始和结束时间（时间戳）
    uint256 public donationStartTime;
    uint256 public donationEndTime;

    // 捐赠事件
    event Donation(address indexed donor, uint256 amount);

    // 提款事件
    event Withdrawal(address indexed owner, uint256 amount);

    // 时间限制设置事件
    event TimeLimitSet(uint256 startTime, uint256 endTime);

    // 构造函数，设置合约所有者
    constructor() {
        owner = msg.sender;
        // 默认设置捐赠时间为永久开放
        donationStartTime = 0;
        donationEndTime = type(uint256).max;
    }

    // 修饰符：只有合约所有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 捐赠函数 - 允许用户向合约发送以太币
    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(block.timestamp >= donationStartTime, "Donation period has not started yet");
        require(block.timestamp <= donationEndTime, "Donation period has ended");

        // 记录捐赠金额
        donations[msg.sender] += msg.value;

        // 如果是新捐赠者，添加到捐赠者列表
        bool isNewDonor = true;
        for (uint i = 0; i < donors.length; i++) {
            if (donors[i] == msg.sender) {
                isNewDonor = false;
                break;
            }
        }

        if (isNewDonor) {
            donors.push(msg.sender);
        }

        // 触发捐赠事件
        emit Donation(msg.sender, msg.value);
    }

    // 提款函数 - 允许合约所有者提取所有资金
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        // 转移所有资金给所有者
        payable(owner).transfer(balance);

        // 触发提款事件
        emit Withdrawal(owner, balance);
    }

    // 查询某个地址的捐赠金额
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }

    // 获取捐赠者总数
    function getDonorsCount() external view returns (uint256) {
        return donors.length;
    }

    // 获取合约余额
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 获取捐赠排行榜前3名
    function getTopDonors() external view returns (address[] memory, uint256[] memory) {
        uint256 donorsCount = donors.length;
        uint256 resultSize = donorsCount < 3 ? donorsCount : 3;

        address[] memory topDonors = new address[](resultSize);
        uint256[] memory topAmounts = new uint256[](resultSize);

        // 复制捐赠者数组用于排序
        address[] memory sortedDonors = new address[](donorsCount);
        for (uint i = 0; i < donorsCount; i++) {
            sortedDonors[i] = donors[i];
        }

        // 简单的冒泡排序，按捐赠金额降序排列
        for (uint i = 0; i < donorsCount - 1; i++) {
            for (uint j = 0; j < donorsCount - i - 1; j++) {
                if (donations[sortedDonors[j]] < donations[sortedDonors[j + 1]]) {
                    address temp = sortedDonors[j];
                    sortedDonors[j] = sortedDonors[j + 1];
                    sortedDonors[j + 1] = temp;
                }
            }
        }

        // 取前3名
        for (uint i = 0; i < resultSize; i++) {
            topDonors[i] = sortedDonors[i];
            topAmounts[i] = donations[sortedDonors[i]];
        }

        return (topDonors, topAmounts);
    }

    // 设置捐赠时间限制（只有所有者可以调用）
    function setDonationTimeLimit(uint256 startTime, uint256 endTime) external onlyOwner {
        require(startTime < endTime, "Start time must be before end time");
        require(endTime > block.timestamp, "End time must be in the future");

        donationStartTime = startTime;
        donationEndTime = endTime;

        emit TimeLimitSet(startTime, endTime);
    }

    // 接收以太币的fallback函数
    receive() external payable {
        donate();
    }
}

