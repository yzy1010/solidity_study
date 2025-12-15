// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortedArray {

    /**
     * @dev 合并两个有序数组为一个有序数组
     * @param arr1 第一个有序数组
     * @param arr2 第二个有序数组
     * @return 合并后的有序数组
     */
    function mergeSortedArrays(uint256[] memory arr1, uint256[] memory arr2)
        public pure returns (uint256[] memory) {

        uint256 len1 = arr1.length;
        uint256 len2 = arr2.length;

        // 创建结果数组
        uint256[] memory result = new uint256[](len1 + len2);

        uint256 i = 0; // arr1的索引
        uint256 j = 0; // arr2的索引
        uint256 k = 0; // result的索引

        // 同时遍历两个数组，选择较小的元素放入结果数组
        while (i < len1 && j < len2) {
            if (arr1[i] <= arr2[j]) {
                result[k] = arr1[i];
                i++;
            } else {
                result[k] = arr2[j];
                j++;
            }
            k++;
        }

        // 如果arr1还有剩余元素，全部添加到结果数组
        while (i < len1) {
            result[k] = arr1[i];
            i++;
            k++;
        }

        // 如果arr2还有剩余元素，全部添加到结果数组
        while (j < len2) {
            result[k] = arr2[j];
            j++;
            k++;
        }

        return result;
    }

    /**
     * @dev 合并两个有序数组（原地合并版本）
     * 假设arr1有足够的空间容纳arr2的元素
     * @param arr1 第一个有序数组（有足够空间）
     * @param m arr1中实际元素的数量
     * @param arr2 第二个有序数组
     * @param n arr2中元素的数量
     * @return 合并后的数组长度
     */
    function mergeInPlace(uint256[] memory arr1, uint256 m, uint256[] memory arr2, uint256 n)
        public pure returns (uint256) {

        uint256 i = m - 1; // arr1的最后一个元素索引
        uint256 j = n - 1; // arr2的最后一个元素索引
        uint256 k = m + n - 1; // 结果数组的最后一个位置索引

        // 从后往前合并，避免覆盖未处理的元素
        while (i >= 0 && j >= 0) {
            if (arr1[i] > arr2[j]) {
                arr1[k] = arr1[i];
                i--;
            } else {
                arr1[k] = arr2[j];
                j--;
            }
            k--;
        }

        // 如果arr2还有剩余元素，复制到arr1前面
        while (j >= 0) {
            arr1[k] = arr2[j];
            j--;
            k--;
        }

        return m + n;
    }

    /**
     * @dev 测试函数 - 合并示例数组
     */
    function testMerge() public pure returns (uint256[] memory) {
        uint256[] memory arr1 = new uint256[](4);
        arr1[0] = 1;
        arr1[1] = 3;
        arr1[2] = 5;
        arr1[3] = 7;

        uint256[] memory arr2 = new uint256[](3);
        arr2[0] = 2;
        arr2[1] = 4;
        arr2[2] = 6;

        return mergeSortedArrays(arr1, arr2);
        // 预期结果: [1, 2, 3, 4, 5, 6, 7]
    }

    /**
     * @dev 测试函数2 - 包含重复元素的合并
     */
    function testMergeWithDuplicates() public pure returns (uint256[] memory) {
        uint256[] memory arr1 = new uint256[](3);
        arr1[0] = 1;
        arr1[1] = 2;
        arr1[2] = 2;

        uint256[] memory arr2 = new uint256[](4);
        arr2[0] = 2;
        arr2[1] = 3;
        arr2[2] = 4;
        arr2[3] = 5;

        return mergeSortedArrays(arr1, arr2);
        // 预期结果: [1, 2, 2, 2, 3, 4, 5]
    }

    /**
     * @dev 验证数组是否有序
     * @param arr 要验证的数组
     * @return 是否有序
     */
    function isSorted(uint256[] memory arr) public pure returns (bool) {
        if (arr.length <= 1) return true;

        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] < arr[i-1]) {
                return false;
            }
        }

        return true;
    }

    /**
     * @dev 打印数组内容（用于调试）
     * @param arr 要打印的数组
     * @return 数组内容的字符串表示
     */
    function arrayToString(uint256[] memory arr) public pure returns (string memory) {
        if (arr.length == 0) return "[]";

        string memory result = "[";
        for (uint256 i = 0; i < arr.length; i++) {
            result = string(abi.encodePacked(result, uint2str(arr[i])));
            if (i < arr.length - 1) {
                result = string(abi.encodePacked(result, ", "));
            }
        }
        result = string(abi.encodePacked(result, "]"));

        return result;
    }

    /**
     * @dev 辅助函数：将uint转换为string
     */
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

