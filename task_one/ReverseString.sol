// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReverseString {

    /**
     * @dev 反转字符串
     * @param input 输入的字符串
     * @return 反转后的字符串
     */
    function reverse(string memory input) public pure returns (string memory) {
        // 将字符串转换为字节数组以便操作
        bytes memory inputBytes = bytes(input);
        uint256 length = inputBytes.length;

        // 创建一个新的字节数组来存储反转后的结果
        bytes memory reversedBytes = new bytes(length);

        // 从后往前遍历原字符串，从前向后填充新数组
        for (uint256 i = 0; i < length; i++) {
            reversedBytes[i] = inputBytes[length - 1 - i];
        }

        // 将字节数组转换回字符串并返回
        return string(reversedBytes);
    }

    /**
     * @dev 测试函数 - 反转 "abcde"
     * @return 反转后的字符串 "edcba"
     */
    function testReverse() public pure returns (string memory) {
        return reverse("abcde");
    }
}

