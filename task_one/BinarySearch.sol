// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinarySearch {

    /**
     * @dev 在有序数组中查找目标值（返回索引）
     * @param arr 有序数组
     * @param target 目标值
     * @return 目标值的索引，如果未找到返回-1
     */
    function binarySearch(int256[] memory arr, int256 target)
        public pure returns (int256) {

        // 检查数组是否为空
        if (arr.length == 0) {
            return -1;
        }

        int256 left = 0;
        int256 right = int256(arr.length) - 1;

        while (left <= right) {
            // 防止整数溢出
            int256 mid = left + (right - left) / 2;

            if (arr[uint256(mid)] == target) {
                return mid; // 找到目标值，返回索引
            } else if (arr[uint256(mid)] < target) {
                left = mid + 1; // 目标值在右半部分
            } else {
                right = mid - 1; // 目标值在左半部分
            }
        }

        return -1; // 未找到目标值
    }

    /**
     * @dev 在有序数组中查找目标值（返回是否存在）
     * @param arr 有序数组
     * @param target 目标值
     * @return 是否找到目标值
     */
    function binarySearchExists(int256[] memory arr, int256 target)
        public pure returns (bool) {
        return binarySearch(arr, target) != -1;
    }

    /**
     * @dev 查找目标值的左边界（第一个等于目标值的位置）
     * @param arr 有序数组
     * @param target 目标值
     * @return 左边界索引，如果未找到返回-1
     */
    function binarySearchLeftBound(int256[] memory arr, int256 target)
        public pure returns (int256) {

        if (arr.length == 0) {
            return -1;
        }

        int256 left = 0;
        int256 right = int256(arr.length) - 1;
        int256 result = -1;

        while (left <= right) {
            int256 mid = left + (right - left) / 2;

            if (arr[uint256(mid)] == target) {
                result = mid; // 记录找到的位置
                right = mid - 1; // 继续在左半部分查找
            } else if (arr[uint256(mid)] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return result;
    }

    /**
     * @dev 查找目标值的右边界（最后一个等于目标值的位置）
     * @param arr 有序数组
     * @param target 目标值
     * @return 右边界索引，如果未找到返回-1
     */
    function binarySearchRightBound(int256[] memory arr, int256 target)
        public pure returns (int256) {

        if (arr.length == 0) {
            return -1;
        }

        int256 left = 0;
        int256 right = int256(arr.length) - 1;
        int256 result = -1;

        while (left <= right) {
            int256 mid = left + (right - left) / 2;

            if (arr[uint256(mid)] == target) {
                result = mid; // 记录找到的位置
                left = mid + 1; // 继续在右半部分查找
            } else if (arr[uint256(mid)] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return result;
    }

    /**
     * @dev 查找第一个大于等于目标值的位置
     * @param arr 有序数组
     * @param target 目标值
     * @return 第一个大于等于目标值的索引
     */
    function binarySearchLowerBound(int256[] memory arr, int256 target)
        public pure returns (int256) {

        if (arr.length == 0) {
            return 0;
        }

        int256 left = 0;
        int256 right = int256(arr.length);

        while (left < right) {
            int256 mid = left + (right - left) / 2;

            if (arr[uint256(mid)] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left;
    }

    /**
     * @dev 查找第一个大于目标值的位置
     * @param arr 有序数组
     * @param target 目标值
     * @return 第一个大于目标值的索引
     */
    function binarySearchUpperBound(int256[] memory arr, int256 target)
        public pure returns (int256) {

        if (arr.length == 0) {
            return 0;
        }

        int256 left = 0;
        int256 right = int256(arr.length);

        while (left < right) {
            int256 mid = left + (right - left) / 2;

            if (arr[uint256(mid)] <= target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left;
    }

    /**
     * @dev 测试函数 - 基本二分查找
     */
    function testBasicSearch() public pure returns (int256, int256, int256) {
        int256[] memory arr = new int256[](7);
        arr[0] = 1;
        arr[1] = 3;
        arr[2] = 5;
        arr[3] = 7;
        arr[4] = 9;
        arr[5] = 11;
        arr[6] = 13;

        // 查找存在的值
        int256 index1 = binarySearch(arr, 7);  // 应该返回 3
        // 查找不存在的值
        int256 index2 = binarySearch(arr, 6);  // 应该返回 -1
        // 查找边界值
        int256 index3 = binarySearch(arr, 1);  // 应该返回 0

        return (index1, index2, index3);
    }

    /**
     * @dev 测试函数 - 查找重复元素的边界
     */
    function testBoundarySearch() public pure returns (int256, int256) {
        int256[] memory arr = new int256[](8);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 2;
        arr[3] = 2;
        arr[4] = 3;
        arr[5] = 4;
        arr[6] = 4;
        arr[7] = 5;

        // 查找重复元素2的左右边界
        int256 leftBound = binarySearchLeftBound(arr, 2);   // 应该返回 1
        int256 rightBound = binarySearchRightBound(arr, 2); // 应该返回 3

        return (leftBound, rightBound);
    }

    /**
     * @dev 验证数组是否有序
     * @param arr 要验证的数组
     * @return 是否有序
     */
    function isSorted(int256[] memory arr) public pure returns (bool) {
        if (arr.length <= 1) return true;

        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] < arr[i-1]) {
                return false;
            }
        }

        return true;
    }
}

