pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSwap {

    // Mapping lưu trữ tỷ giá hối đoái cho mỗi cặp mã thông báo
    mapping(address => mapping(address => uint256)) public rates;

    // Mapping lưu trữ địa chỉ token cho mỗi native token (BNB, ETH)
    mapping(address => address) public nativeTokens;

    // Địa chỉ admin
    address public admin;

    event Swap(address indexed sender, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    constructor() {
        admin = msg.sender;
    }

    // Hàm cho phép admin thiết lập tỷ giá hối đoái cho một cặp mã thông báo
    function setRate(address tokenA, address tokenB, uint256 rate) external onlyAdmin {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token addresses");
        rates[tokenA][tokenB] = rate;
    }

    // Hàm cho phép admin thiết lập địa chỉ token cho native token (BNB, ETH)
    function setNativeToken(address token, address nativeToken) external onlyAdmin {
        require(token != address(0) && nativeToken != address(0), "Invalid token addresses");
        nativeTokens[token] = nativeToken;
    }

    // Hàm cho phép người dùng swap token
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external {
        require(tokenIn != address(0) && tokenOut != address(0), "Invalid token addresses");
        require(amountIn > 0, "Invalid amount");

        // Tính toán số lượng token out nhận được
        uint256 amountOut = calculateAmountOut(tokenIn, tokenOut, amountIn);

        // Chuyển token in cho hợp đồng
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Chuyển token out cho người dùng
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    // Hàm tính toán số lượng token out nhận được
    function calculateAmountOut(address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) {
        uint256 rateIn = getRate(tokenIn);
        uint256 rateOut = getRate(tokenOut);

        require(rateIn > 0 && rateOut > 0, "Invalid rates");

        return amountIn * rateOut / rateIn;
    }

    // Hàm lấy tỷ giá hối đoái cho một mã thông báo
    function getRate(address token) public view returns (uint256) {
        address nativeToken = nativeTokens[token];
        require(nativeToken != address(0), "Invalid native token");

        return rates[token][nativeToken];
    }

    // Modifier chỉ cho phép admin thực thi hàm
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
}