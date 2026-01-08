// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@chainlink/contracts/node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {Ownable} from "@chainlink/contracts/src/v0.4/vendor/Ownable.sol";
import {Ownable} from "@chainlink/contracts/src/v0.5/vendor/Ownable.sol";
import {Ownable} from "@chainlink/contracts/src/v0.6/vendor/Ownable.sol";
import {Ownable} from "@openzeppelin/contracts-v0.7/access/Ownable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "hardhat-deploy/solc_0.8/openzeppelin/access/Ownable.sol";

/**
 * @title NFT
 * @dev Implementation of the ERC721 standard with metadata storage
 */
contract NFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    // Counter for token IDs
    Counters.Counter private _tokenIdCounter;

    // Mapping from token ID to auction status
    mapping(uint256 => bool) public isTokenOnAuction;

    // Base URI for token metadata
    string private _baseTokenURI;

    // Auction contract address
    address public auctionContract;

    /**
     * @dev Constructor that initializes the contract
     * @param name_ The name of the NFT collection
     * @param symbol_ The symbol of the NFT collection
     * @param baseTokenURI_ The base URI for token metadata
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseTokenURI_
    ) ERC721(name_, symbol_) {
        _baseTokenURI = baseTokenURI_;
    }

    /**
     * @dev Sets the auction contract address
     * @param auctionAddress The address of the auction contract
     */
    function setAuctionContract(address auctionAddress) external onlyOwner {
        require(auctionAddress != address(0), "Invalid auction contract address");
        auctionContract = auctionAddress;
    }

    /**
     * @dev Mints a new NFT
     * @param recipient The address to mint the NFT to
     * @param tokenURI The URI for the token metadata
     * @return The token ID of the minted NFT
     */
    function mintNFT(
        address recipient,
        string memory tokenURI
    ) external onlyOwner returns (uint256) {
        require(recipient != address(0), "Invalid recipient address");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }

    /**
     * @dev Internal function to set the base token URI
     * @param baseTokenURI_ The new base token URI
     */
    function _setBaseTokenURI(string memory baseTokenURI_) internal {
        _baseTokenURI = baseTokenURI_;
    }

    /**
     * @dev Returns the base URI for all token IDs
     */
    function baseTokenURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Returns the token URI for a given token ID
     * @param tokenId The token ID
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "Token does not exist");

        string memory baseURI = _baseTokenURI;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, Strings.toString(tokenId))) : "";
    }

    /**
     * @dev Sets the status of a token being on auction
     * @param tokenId The token ID
     * @param onAuction Whether the token is on auction
     */
    function setTokenOnAuction(uint256 tokenId, bool onAuction) external {
        require(msg.sender == auctionContract, "Only auction contract can call this");
        isTokenOnAuction[tokenId] = onAuction;
    }

    /**
     * @dev Checks if a token is currently on auction
     * @param tokenId The token ID
     */
    function isOnAuction(uint256 tokenId) external view returns (bool) {
        return isTokenOnAuction[tokenId];
    }

    /**
     * @dev Override to prevent transferring NFTs that are on auction
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        // Only allow transfers through auction contract when on auction
        if (isTokenOnAuction[tokenId]) {
            require(
                msg.sender == auctionContract,
                "Token is on auction, only auction contract can transfer"
            );
        }
    }

    /**
     * @dev Prevents burning tokens that are on auction
     */
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        require(!isTokenOnAuction[tokenId], "Cannot burn token that is on auction");
        super._burn(tokenId);
    }
}

