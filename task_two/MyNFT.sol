// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MyNFT
 * @dev 符合ERC721标准的NFT合约，支持铸造和元数据
 */

contract MyNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    // 代币ID计数器
    Counters.Counter private _tokenIdCounter;

    // 铸造事件
    event NFTMinted(address indexed recipient, uint256 indexed tokenId, string tokenURI);

    /**
     * @dev 构造函数
     * @param name NFT名称
     * @param symbol NFT符号
     */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    /**
     * @dev 铸造NFT函数
     * @param recipient 接收NFT的地址
     * @param tokenURI NFT的元数据URI（IPFS链接）
     * @return 新铸造的NFT的tokenId
     */
    function mintNFT(address recipient, string memory tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        // 递增tokenId
        _tokenIdCounter.increment();
        uint256 newItemId = _tokenIdCounter.current();

        // 铸造NFT
        _safeMint(recipient, newItemId);

        // 设置tokenURI
        _setTokenURI(newItemId, tokenURI);

        // 触发铸造事件
        emit NFTMinted(recipient, newItemId, tokenURI);

        return newItemId;
    }

    /**
     * @dev 获取下一个可用的tokenId
     * @return 下一个tokenId
     */
    function getNextTokenId() public view returns (uint256) {
        return _tokenIdCounter.current() + 1;
    }

    /**
     * @dev 获取已铸造的NFT总数
     * @return 已铸造的NFT数量
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    /**
     * @dev 重写ERC721URIStorage的burn函数，添加onlyOwner修饰符
     */
    function burn(uint256 tokenId) public override onlyOwner {
        super.burn(tokenId);
    }

    /**
     * @dev 重写supportsInterface函数以支持ERC721和ERC721URIStorage接口
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

