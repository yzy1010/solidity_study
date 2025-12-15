// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntegerToRoman {

    /**
     * @dev 将整数转换为罗马数字
     * @param num 要转换的整数 (1-3999)
     * @return 对应的罗马数字字符串
     */
    function intToRoman(uint256 num) public pure returns (string memory) {
        // 验证输入范围
        require(num >= 1 && num <= 3999, "数字必须在1-3999范围内");

        // 定义罗马数字的对应关系（从大到小排列）
        uint256[] memory values = new uint256[](13);
        string[] memory symbols = new string[](13);

        // 初始化数值和符号数组
        values[0] = 1000; symbols[0] = "M";
        values[1] = 900;  symbols[1] = "CM";
        values[2] = 500;  symbols[2] = "D";
        values[3] = 400;  symbols[3] = "CD";
        values[4] = 100;  symbols[4] = "C";
        values[5] = 90;   symbols[5] = "XC";
        values[6] = 50;   symbols[6] = "L";
        values[7] = 40;   symbols[7] = "XL";
        values[8] = 10;   symbols[8] = "X";
        values[9] = 9;    symbols[9] = "IX";
        values[10] = 5;   symbols[10] = "V";
        values[11] = 4;   symbols[11] = "IV";
        values[12] = 1;   symbols[12] = "I";

        // 构建结果字符串
        string memory result = "";

        // 从大到小遍历所有罗马数字符号
        for (uint256 i = 0; i < values.length; i++) {
            // 当当前数值小于等于剩余数字时，添加对应的罗马符号
            while (num >= values[i]) {
                result = string(abi.encodePacked(result, symbols[i]));
                num -= values[i];
            }
        }

        return result;
    }

    /**
     * @dev 测试函数 - 转换一些常见数字
     */
    function testConversions() public pure returns (
        string memory, // 3 -> "III"
        string memory, // 4 -> "IV"
        string memory, // 9 -> "IX"
        string memory, // 58 -> "LVIII"
        string memory  // 1994 -> "MCMXCIV"
    ) {
        return (
            intToRoman(3),
            intToRoman(4),
            intToRoman(9),
            intToRoman(58),
            intToRoman(1994)
        );
    }

    /**
     * @dev 测试单个数字转换
     * @param num 要测试的数字
     * @return 转换结果
     */
    function testSingle(uint256 num) public pure returns (string memory) {
        return intToRoman(num);
    }
}

