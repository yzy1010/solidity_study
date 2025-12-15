// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomanToInteger {

    /**
     * @dev 将罗马数字转换为整数
     * @param s 罗马数字字符串
     * @return 对应的整数值
     */
    function romanToInt(string memory s) public pure returns (uint256) {
        // 验证输入不为空
        require(bytes(s).length > 0, "罗马数字不能为空");

        uint256 result = 0;
        uint256 length = bytes(s).length;

        // 从左到右遍历罗马数字字符串
        for (uint256 i = 0; i < length; i++) {
            // 获取当前字符的值
            uint256 currentVal = getRomanValue(s[i]);

            // 检查是否有下一个字符
            if (i + 1 < length) {
                uint256 nextVal = getRomanValue(s[i + 1]);

                // 如果当前值小于下一个值，说明是减法情况（如IV, IX等）
                if (currentVal < nextVal) {
                    result += (nextVal - currentVal);
                    i++; // 跳过下一个字符，因为已经处理过了
                    continue;
                }
            }

            // 正常情况：直接加上当前值
            result += currentVal;
        }

        return result;
    }

    /**
     * @dev 获取单个罗马字符对应的数值
     * @param c 罗马字符
     * @return 对应的数值
     */
    function getRomanValue(bytes1 c) internal pure returns (uint256) {
        if (c == "I") return 1;
        if (c == "V") return 5;
        if (c == "X") return 10;
        if (c == "L") return 50;
        if (c == "C") return 100;
        if (c == "D") return 500;
        if (c == "M") return 1000;

        // 如果遇到无效字符，可以revert或返回0
        revert("无效的罗马数字字符");
    }

    /**
     * @dev 测试函数 - 转换一些常见罗马数字
     */
    function testConversions() public pure returns (
        uint256, // "III" -> 3
        uint256, // "IV" -> 4
        uint256, // "IX" -> 9
        uint256, // "LVIII" -> 58
        uint256  // "MCMXCIV" -> 1994
    ) {
        return (
            romanToInt("III"),
            romanToInt("IV"),
            romanToInt("IX"),
            romanToInt("LVIII"),
            romanToInt("MCMXCIV")
        );
    }

    /**
     * @dev 测试单个罗马数字转换
     * @param s 要测试的罗马数字
     * @return 转换结果
     */
    function testSingle(string memory s) public pure returns (uint256) {
        return romanToInt(s);
    }

    /**
     * @dev 验证罗马数字格式是否有效
     * @param s 罗马数字字符串
     * @return 是否有效
     */
    function isValidRoman(string memory s) public pure returns (bool) {
        uint256 length = bytes(s).length;
        if (length == 0) return false;

        for (uint256 i = 0; i < length; i++) {
            bytes1 c = s[i];
            if (c != "I" && c != "V" && c != "X" && c != "L" &&
                c != "C" && c != "D" && c != "M") {
                return false;
            }
        }

        // 尝试转换，如果成功则格式正确
        try this.romanToInt(s) {
            return true;
        } catch {
            return false;
        }
    }
}

