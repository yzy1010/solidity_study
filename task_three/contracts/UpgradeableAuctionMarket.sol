// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConsumerV3} from "./PriceConsumerV3.sol";
import {Initializable} from "@chainlink/contracts/node_modules/@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-v0.7/proxy/Initializable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/upgrades-core/contracts/Initializable.sol";
import {Initializable} from "hardhat-deploy/solc_0.8/openzeppelin/proxy/utils/Initializable.sol";

/**
 * @title UpgradeableAuctionMarket
 * @dev Upgradeable version of the NFT Auction Market using UUPS pattern
 */
contract UpgradeableAuctionMarket is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    struct Auction {
        uint256 tokenId;
        address nftContract;
        address payable seller;
        uint256 startingPrice;
        uint256 reservePrice;
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        bool isERC20Payment;
        address erc20Token;
        bool ended;
        uint256 auctionId;
    }

    struct Bid {
        address bidder;
        uint256 amount;
        uint256 timestamp;
        bool isERC20;
        address token;
    }

    // State variables
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => Bid[]) public auctionBids;
    mapping(address => mapping(uint256 => uint256)) public pendingReturns;
    mapping(address => uint256) public platformFees;

    uint256 public nextAuctionId = 1;
    uint256 public platformFeePercentage;
    address public nftContractAddress;
    address public erc20TokenAddress;

    // Price feeds
    PriceConsumerV3 public ethUsdPriceFeed;
    PriceConsumerV3 public erc20UsdPriceFeed;

    // Events
    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 endTime,
        bool isERC20Payment
    );

    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount,
        bool isERC20,
        uint256 usdValue
    );

    event AuctionEnded(
        uint256 indexed auctionId,
        address indexed winner,
        uint256 winningBid,
        uint256 usdValue
    );

    /**
     * @dev Initialize function (replaces constructor for upgradeable contracts)
     */
    function initialize(
        address _nftContract,
        address _erc20Token,
        address _ethUsdPriceFeed,
        address _erc20UsdPriceFeed,
        uint256 _platformFeePercentage
    ) public initializer {
        require(_nftContract != address(0), "Invalid NFT contract address");
        require(_erc20Token != address(0), "Invalid ERC20 token address");
        require(_ethUsdPriceFeed != address(0), "Invalid ETH/USD price feed");
        require(_erc20UsdPriceFeed != address(0), "Invalid ERC20/USD price feed");
        require(_platformFeePercentage <= 1000, "Fee too high (max 10%)");

        __Ownable_init();
        __ReentrancyGuard_init();

        nftContractAddress = _nftContract;
        erc20TokenAddress = _erc20Token;
        platformFeePercentage = _platformFeePercentage;
        ethUsdPriceFeed = PriceConsumerV3(_ethUsdPriceFeed);
        erc20UsdPriceFeed = PriceConsumerV3(_erc20UsdPriceFeed);
    }

    /**
     * @dev Creates a new auction for an NFT
     */
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _reservePrice,
        uint256 _duration,
        bool _isERC20Payment
    ) external nonReentrant returns (uint256) {
        require(_duration >= 1 hours, "Auction duration too short");
        require(_duration <= 30 days, "Auction duration too long");
        require(_startingPrice > 0, "Starting price must be greater than 0");
        require(_reservePrice >= _startingPrice, "Reserve price must be >= starting price");

        IERC721 nft = IERC721(nftContractAddress);
        require(nft.ownerOf(_tokenId) == msg.sender, "You must own the NFT");
        require(nft.isApprovedForAll(msg.sender, address(this)) ||
                nft.getApproved(_tokenId) == address(this), "Contract not approved");

        uint256 auctionId = nextAuctionId++;

        auctions[auctionId] = Auction({
            tokenId: _tokenId,
            nftContract: nftContractAddress,
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            reservePrice: _reservePrice,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            highestBidder: address(0),
            highestBid: 0,
            isERC20Payment: _isERC20Payment,
            erc20Token: _isERC20Payment ? erc20TokenAddress : address(0),
            ended: false,
            auctionId: auctionId
        });

        // Mark the NFT as being on auction
        (bool success, ) = nftContractAddress.call(
            abi.encodeWithSelector(
                bytes4(keccak256("setTokenOnAuction(uint256,bool)")),
                _tokenId,
                true
            )
        );
        require(success, "Failed to mark NFT as on auction");

        emit AuctionCreated(
            auctionId,
            nftContractAddress,
            _tokenId,
            msg.sender,
            _startingPrice,
            _reservePrice,
            block.timestamp + _duration,
            _isERC20Payment
        );

        return auctionId;
    }

    /**
     * @dev Places a bid on an auction
     */
    function placeBid(uint256 _auctionId) external payable nonReentrant {
        Auction storage auction = auctions[_auctionId];
        require(auction.auctionId != 0, "Auction does not exist");
        require(!auction.ended, "Auction has ended");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.sender != auction.seller, "Seller cannot bid");

        uint256 bidAmount = msg.value;
        bool isERC20 = false;
        address tokenAddress = address(0);

        if (auction.isERC20Payment) {
            require(msg.value == 0, "Cannot send ETH for ERC20 auction");

            // Handle ERC20 payment
            IERC20 erc20Token = IERC20(auction.erc20Token);
            bidAmount = erc20Token.allowance(msg.sender, address(this));
            require(bidAmount > 0, "No allowance given");

            require(
                erc20Token.transferFrom(msg.sender, address(this), bidAmount),
                "ERC20 transfer failed"
            );

            isERC20 = true;
            tokenAddress = auction.erc20Token;
        } else {
            require(msg.value >= auction.startingPrice, "Bid below starting price");
        }

        require(bidAmount > auction.highestBid, "Bid must be higher than current highest");

        // Calculate USD value for comparison
        uint256 usdValue = _calculateUSDValue(bidAmount, isERC20);
        uint256 highestUsdValue = _calculateUSDValue(auction.highestBid, auction.isERC20Payment);

        require(usdValue > highestUsdValue, "Bid USD value must be higher");

        // Refund previous highest bidder
        if (auction.highestBidder != address(0)) {
            pendingReturns[auction.highestBidder][_auctionId] += auction.highestBid;
        }

        // Record the bid
        auctionBids[_auctionId].push(Bid({
            bidder: msg.sender,
            amount: bidAmount,
            timestamp: block.timestamp,
            isERC20: isERC20,
            token: tokenAddress
        }));

        // Update auction state
        auction.highestBidder = msg.sender;
        auction.highestBid = bidAmount;

        emit BidPlaced(_auctionId, msg.sender, bidAmount, isERC20, usdValue);
    }

    /**
     * @dev Ends an auction
     */
    function endAuction(uint256 _auctionId) external nonReentrant {
        Auction storage auction = auctions[_auctionId];
        require(auction.auctionId != 0, "Auction does not exist");
        require(!auction.ended, "Auction already ended");
        require(
            block.timestamp >= auction.endTime ||
            msg.sender == auction.seller ||
            msg.sender == owner(),
            "Auction not ended yet"
        );

        auction.ended = true;

        // Mark NFT as no longer on auction
        IERC721 nft = IERC721(auction.nftContract);
        (bool success, ) = auction.nftContract.call(
            abi.encodeWithSelector(
                bytes4(keccak256("setTokenOnAuction(uint256,bool)")),
                auction.tokenId,
                false
            )
        );
        require(success, "Failed to unmark NFT from auction");

        if (auction.highestBidder != address(0) && auction.highestBid >= auction.reservePrice) {
            // Transfer NFT to winner
            nft.safeTransferFrom(auction.seller, auction.highestBidder, auction.tokenId);

            // Calculate and collect platform fee
            uint256 fee = (auction.highestBid * platformFeePercentage) / 10000;
            platformFees[auction.erc20Token] += fee;

            // Pay seller (after fee)
            uint256 sellerProceeds = auction.highestBid - fee;

            if (auction.isERC20Payment) {
                IERC20 erc20Token = IERC20(auction.erc20Token);
                require(
                    erc20Token.transfer(auction.seller, sellerProceeds),
                    "Failed to transfer ERC20 to seller"
                );
            } else {
                (bool sent, ) = auction.seller.call{value: sellerProceeds}("");
                require(sent, "Failed to send ETH to seller");
            }

            uint256 usdValue = _calculateUSDValue(auction.highestBid, auction.isERC20Payment);

            emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid, usdValue);
        } else {
            // No valid bids, return NFT to seller
            nft.safeTransferFrom(address(this), auction.seller, auction.tokenId);
        }
    }

    /**
     * @dev Claims a refund for an outbid bid
     */
    function claimRefund(uint256 _auctionId) external nonReentrant {
        uint256 refundAmount = pendingReturns[msg.sender][_auctionId];
        require(refundAmount > 0, "No refund available");

        pendingReturns[msg.sender][_auctionId] = 0;

        Auction storage auction = auctions[_auctionId];

        if (auction.isERC20Payment) {
            IERC20 erc20Token = IERC20(auction.erc20Token);
            require(
                erc20Token.transfer(msg.sender, refundAmount),
                "ERC20 transfer failed"
            );
        } else {
            (bool sent, ) = msg.sender.call{value: refundAmount}("");
            require(sent, "ETH transfer failed");
        }
    }

    /**
     * @dev Withdraws platform fees
     */
    function withdrawFees(address _token) external onlyOwner {
        uint256 feeAmount = platformFees[_token];
        require(feeAmount > 0, "No fees to withdraw");

        platformFees[_token] = 0;

        if (_token == address(0)) {
            (bool sent, ) = msg.sender.call{value: feeAmount}("");
            require(sent, "ETH transfer failed");
        } else {
            IERC20 erc20Token = IERC20(_token);
            require(
                erc20Token.transfer(msg.sender, feeAmount),
                "ERC20 transfer failed"
            );
        }
    }

    /**
     * @dev Calculates USD value of an amount
     */
    function _calculateUSDValue(uint256 amount, bool isERC20) internal view returns (uint256) {
        if (amount == 0) return 0;

        if (isERC20) {
            return erc20UsdPriceFeed.convertToUSD(amount, 18);
        } else {
            return ethUsdPriceFeed.convertToUSD(amount, 18);
        }
    }

    /**
     * @dev Gets auction details
     */
    function getAuction(uint256 _auctionId) external view returns (
        uint256 tokenId,
        address nftContract,
        address seller,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 startTime,
        uint256 endTime,
        address highestBidder,
        uint256 highestBid,
        bool isERC20Payment,
        address erc20Token,
        bool ended
    ) {
        Auction storage auction = auctions[_auctionId];
        return (
            auction.tokenId,
            auction.nftContract,
            auction.seller,
            auction.startingPrice,
            auction.reservePrice,
            auction.startTime,
            auction.endTime,
            auction.highestBidder,
            auction.highestBid,
            auction.isERC20Payment,
            auction.erc20Token,
            auction.ended
        );
    }

    /**
     * @dev Updates platform fee percentage
     */
    function setPlatformFee(uint256 _feePercentage) external onlyOwner {
        require(_feePercentage <= 1000, "Fee too high (max 10%)");
        platformFeePercentage = _feePercentage;
    }

    /**
     * @dev UUPS upgrade function
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {
        // Add additional access control if needed
    }

    // Fallback function to accept ETH
    receive() external payable {}
}

