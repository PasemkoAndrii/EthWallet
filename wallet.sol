//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.23;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

interface WethWraping {
    // function which allows us to change real ETH into WETH ERC20 token
    function deposit() external payable;

    // function which allows us to change WETH token to real ETH, and withdraw it back to this contract
    // "wad" is number of tokens we want to withdraw
    function withdraw(uint wad) external;
}


contract Wallet {
    ISwapRouter public swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    WethWraping public wethWrappingInterface = WethWraping(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);

    address WETH_ADDR = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address UNI_ADDR = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;

    uint24 constant poolFee = 3000;

    event ConsoleLog (string, uint);
    
    constructor() {
    }

    fallback () external payable {
        // function needs to receive ETH from externall contract 
    }
    receive () external payable {
    }

    function checkMyBalance (address _tokenAddress) external {
        uint myBalance = IERC20(_tokenAddress).balanceOf(address(this));
        emit ConsoleLog('token balance is',  myBalance);
    }

    function transferAllMyToken (address _tokenAddress, address _destination) external {
        uint myBalance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(_tokenAddress).transfer(_destination, myBalance);
    }

    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {

        TransferHelper.safeApprove(WETH_ADDR, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: WETH_ADDR,
                tokenOut: UNI_ADDR,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }

    function wrapEthToWeth (uint _amount) external {
        wethWrappingInterface.deposit{value: _amount}();
        
        emit ConsoleLog('', address(this).balance);
    }

    function withdrawEthFromWeth (uint _amount) external {
        wethWrappingInterface.withdraw(_amount);
        
        emit ConsoleLog('', address(this).balance);
    }

    function sendAllMyEthToAddress (address payable _destination) external {
        _destination.transfer(address(this).balance);
        emit ConsoleLog('Send all ETH balance', address(this).balance);
    }
}