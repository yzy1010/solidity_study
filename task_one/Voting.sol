// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // mapping来存储候选人的得票数
    mapping(string => uint256) public candidateVotes;

    // 存储所有候选人的数组，用于重置功能
    string[] private candidates;

    // 投票函数，允许用户投票给某个候选人
    function vote(string memory candidate) public {
        require(bytes(candidate).length > 0, "候选人名称不能为空");
        candidateVotes[candidate]++;

        // 如果是新候选人，添加到数组中
        bool exists = false;
        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(bytes(candidates[i])) == keccak256(bytes(candidate))) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            candidates.push(candidate);
        }
    }

    // 获取某个候选人的得票数
    function getVotes(string memory candidate) public view returns (uint256) {
        return candidateVotes[candidate];
    }

    // 重置所有候选人的得票数
    function resetVotes() public {
        // 遍历所有候选人并将得票数重置为0
        for (uint i = 0; i < candidates.length; i++) {
            candidateVotes[candidates[i]] = 0;
        }
    }

    // 获取所有候选人列表
    function getAllCandidates() public view returns (string[] memory) {
        return candidates;
    }

    // 获取候选人总数
    function getCandidatesCount() public view returns (uint256) {
        return candidates.length;
    }
}

