// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@chainlink/contracts/node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {Ownable} from "@chainlink/contracts/src/v0.4/vendor/Ownable.sol";
import {Ownable} from "@chainlink/contracts/src/v0.5/vendor/Ownable.sol";
import {Ownable} from "@chainlink/contracts/src/v0.6/vendor/Ownable.sol";
import {Ownable} from "@openzeppelin/contracts-v0.7/access/Ownable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "hardhat-deploy/solc_0.8/openzeppelin/access/Ownable.sol";

/**
 * @title MyToken
 * @dev Simple ERC20 token for auction bidding
 */
contract MyToken is ERC20, Ownable {
    /**
     * @dev Constructor that initializes the contract
     */
    constructor() ERC20("Auction Token", "AUC") {
        // Mint initial supply to the deployer
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    /**
     * @dev Allows the owner to mint new tokens
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

