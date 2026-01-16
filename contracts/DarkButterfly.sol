// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  Simple ERC20 with buy/sell taxes (percent integers) and auto-swap-to-ETH forwarding to marketing wallet.
  - buyFeePercent and sellFeePercent default to 5 (5%)
  - Requires a UniswapV2-compatible router (e.g., Uniswap, PancakeSwap)
  - Owner can exclude addresses from fees, change fee percentages up to maxFeePercent, set the marketing wallet.
  - WARNING: This is a starter template. Audit before using in production.
*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract DarkButterfly is ERC20, Ownable {
    IUniswapV2Router02 public router;
    address public pair; // AMM pair address (set by owner)
    address public marketingWallet;

    uint256 public buyFeePercent;  // e.g., 5 == 5%
    uint256 public sellFeePercent; // e.g., 5 == 5%
    uint256 public constant maxFeePercent = 10; // safety cap

    mapping(address => bool) public isExcludedFromFee;
    bool private swapping;
    uint256 public swapThreshold; // number of tokens accumulated in contract before swap

    event FeesUpdated(uint256 buyFee, uint256 sellFee);
    event MarketingWalletUpdated(address wallet);
    event ExcludeFromFee(address account, bool excluded);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address routerAddress,
        address marketingWallet_
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply);

        router = IUniswapV2Router02(routerAddress);
        marketingWallet = marketingWallet_;
        buyFeePercent = 5;
        sellFeePercent = 5;
        swapThreshold = initialSupply / 10000; // 0.01% of supply default
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[marketingWallet] = true;
    }

    receive() external payable {}

    function setPair(address pairAddress) external onlyOwner {
        pair = pairAddress;
    }

    function setFees(uint256 _buyFeePercent, uint256 _sellFeePercent) external onlyOwner {
        require(_buyFeePercent <= maxFeePercent && _sellFeePercent <= maxFeePercent, "fee too high");
        buyFeePercent = _buyFeePercent;
        sellFeePercent = _sellFeePercent;
        emit FeesUpdated(_buyFeePercent, _sellFeePercent);
    }

    function setMarketingWallet(address wallet) external onlyOwner {
        marketingWallet = wallet;
        isExcludedFromFee[wallet] = true;
        emit MarketingWalletUpdated(wallet);
    }

    function setSwapThreshold(uint256 threshold) external onlyOwner {
        swapThreshold = threshold;
    }

    function excludeFromFee(address account, bool excluded) external onlyOwner {
        isExcludedFromFee[account] = excluded;
        emit ExcludeFromFee(account, excluded);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        // If any party is excluded or fees are zero, do a normal transfer
        if (isExcludedFromFee[from] || isExcludedFromFee[to] || (buyFeePercent == 0 && sellFeePercent == 0)) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 feePercent = 0;
        // Identify buy or sell based on pair involvement
        if (from == pair) {
            // buy
            feePercent = buyFeePercent;
        } else if (to == pair) {
            // sell
            feePercent = sellFeePercent;
        } else {
            // normal transfer between wallets — no fee by default
            feePercent = 0;
        }

        if (feePercent == 0) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 feeAmount = (amount * feePercent) / 100;
        uint256 sendAmount = amount - feeAmount;

        // Transfer fee to contract
        super._transfer(from, address(this), feeAmount);
        super._transfer(from, to, sendAmount);

        // If contract token balance meets threshold, swap to ETH and send to marketing wallet
        uint256 contractTokenBalance = balanceOf(address(this));
        if (!swapping && contractTokenBalance >= swapThreshold && from != pair) {
            swapping = true;
            swapTokensForEthAndSend(contractTokenBalance);
            swapping = false;
        }
    }

    function swapTokensForEthAndSend(uint256 tokenAmount) internal {
        // approve router
        _approve(address(this), address(router), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        // swap tokens for ETH, send ETH to this contract
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        // forward ETH to marketingWallet
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            (bool success,) = marketingWallet.call{value: ethBalance}("");
            require(success, "ETH transfer failed");
        }
    }

    // Rescue tokens accidentally sent to contract (owner only)
    function rescueERC20(address tokenAddress, uint256 amount, address to) external onlyOwner {
        IERC20(tokenAddress).transfer(to, amount);
    }

    // Owner can withdraw any ETH accidentally left (emergency)
    function rescueETH(address to) external onlyOwner {
        (bool success,) = to.call{value: address(this).balance}("");
        require(success, "ETH transfer failed");
    }
}
