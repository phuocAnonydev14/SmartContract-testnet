// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSwap {

    // Mapping lưu trữ tỷ giá hối đoái cho mỗi cặp mã thông báo
    mapping(address => mapping(address => uint256)) public rates;

    // Địa chỉ admin
    address public admin;

    event Swap(address indexed sender, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    constructor() {
        admin = msg.sender;
    }

    // Hàm cho phép admin thiết lập tỷ giá hối đoái cho một cặp mã thông báo
    function setRate(address _tokenA, address _tokenB, uint256 _rate) external onlyAdmin {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token addresses");
        rates[_tokenA][_tokenB] = _rate;
    }

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn) external payable {
        require(_tokenIn != address(0) && _tokenOut != address(0), "Invalid token addresses");
        require(_amountIn > 0, "Invalid amount");

        uint256 amountOut = calculateAmountOut(_tokenIn, _tokenOut, _amountIn);
        
        _handleAmountIn(_tokenIn, _amountIn);
        _handleAmountOut(_tokenOut, amountOut);

        emit Swap(msg.sender, _tokenIn, _tokenOut, _amountIn, amountOut);
    }

    function calculateAmountOut(address _tokenIn, address _tokenOut, uint256 _amountIn) public view returns (uint256) {
        uint256 rateIn = getRate(_tokenIn,_tokenOut);
        uint256 rateOut = getRate(_tokenOut,_tokenIn);

        require(rateIn > 0 && rateOut > 0, "Invalid rates");

        return _amountIn * rateOut / rateIn;
    }

    function _handleAmountIn(address _tokenIn, uint _amountIn) internal {
        if(_isNativeToken(_tokenIn)) {
            require(_amountIn == msg.value, "Amount must be equal to msg.value");        
            return;
        }
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    }

    function _handleAmountOut(address _tokenOut, uint _amountOut) internal {
        if(_isNativeToken(_tokenOut)) {
            (bool sent,) = msg.sender.call{value: _amountOut}("");
            require(sent, "Failed to send Ether");  
            return;
        }
        IERC20(_tokenOut).transfer(msg.sender, _amountOut);
    }

    function getRate(address _token1,address _token2) public view returns (uint256) {
        return rates[_token1][_token2];
    }

    // Modifier only admin execute function
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function _isNativeToken(address _address) internal pure returns(bool) {
        return _address == address(0);
    }
}