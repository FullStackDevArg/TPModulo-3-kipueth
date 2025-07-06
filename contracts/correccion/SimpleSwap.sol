// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Definition of the ISimpleSwap interface within the file
interface ISimpleSwap {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getPrice(address tokenA, address tokenB) external view returns (uint256 price);
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external view returns (uint256);
}

/**
 * @title SimpleSwap
 * @dev Basic AMM for swaps and liquidity.
 */
contract SimpleSwap is ISimpleSwap {
    address public tokenA;
    address public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public totalLiquidity;

    mapping(address => uint256) public liquidity;

    /**
     * @notice Emitted on liquidity add.
     * @param provider Addr adding liquidity.
     * @param amountA Amt of tokenA added.
     * @param amountB Amt of tokenB added.
     * @param liquidity Amt of liquidity minted.
     */
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);

    /**
     * @notice Emitted on liquidity removal.
     * @param provider Addr removing liquidity.
     * @param amountA Amt of tokenA removed.
     * @param amountB Amt of tokenB removed.
     */
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);

    /**
     * @notice Emitted on swap.
     * @param user Addr performing swap.
     * @param amountIn Amt of input tokens.
     * @param amountOut Amt of output tokens.
     */
    event Swap(address indexed user, uint256 amountIn, uint256 amountOut);

    /**
     * @notice Sets token addresses.
     * @dev Ensures valid, different tokens.
     * @param _tokenA Addr of tokenA.
     * @param _tokenB Addr of tokenB.
     */
    constructor(address _tokenA, address _tokenB) {
        require(_tokenA != address(0) && _tokenB != address(0), "Inv token addr");
        require(_tokenA != _tokenB, "Tokens must differ");
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    /**
     * @notice Adds liquidity to pool.
     * @dev Transfers tokens, mints liquidity.
     * @param tokenA_ Ignored param, uses tokenA.
     * @param tokenB_ Ignored param, uses tokenB.
     * @param amountADesired Amt of tokenA to add.
     * @param amountBDesired Amt of tokenB to add.
     * @param amountAMin Min amt of tokenA.
     * @param amountBMin Min amt of tokenB.
     * @param to Addr to get liquidity.
     * @param deadline Ignored param.
     * @return amountA Amt of tokenA added.
     * @return amountB Amt of tokenB added.
     * @return liquidityMinted Amt of liquidity.
     */
    function addLiquidity(
        address tokenA_,
        address tokenB_,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external override returns (uint256 amountA, uint256 amountB, uint256 liquidityMinted) {
        require(to != address(0), "Inv to addr");
        require(amountADesired >= amountAMin && amountBDesired >= amountBMin, "Min amts not met");

        if (totalLiquidity == 0) {
            require(amountADesired > 0 && amountBDesired > 0, "Init liq must be pos");
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            uint256 amountBOptimal = (amountADesired * reserveB) / reserveA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "Insuf B amt");
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint256 amountAOptimal = (amountBDesired * reserveA) / reserveB;
                require(amountAOptimal >= amountAMin, "Insuf A amt");
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        }

        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "Trans A fail");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "Trans B fail");

        if (totalLiquidity == 0) {
            liquidityMinted = amountA;
        } else {
            liquidityMinted = (amountA * totalLiquidity) / reserveA;
        }

        reserveA += amountA;
        reserveB += amountB;
        totalLiquidity += liquidityMinted;
        liquidity[to] += liquidityMinted;

        emit LiquidityAdded(to, amountA, amountB, liquidityMinted);
    }

    /**
     * @notice Removes liquidity from pool.
     * @dev Burns liquidity, transfers tokens.
     * @param tokenA_ Ignored param, uses tokenA.
     * @param tokenB_ Ignored param, uses tokenB.
     * @param liquidityAmount Amt of liquidity to remove.
     * @param amountAMin Min amt of tokenA.
     * @param amountBMin Min amt of tokenB.
     * @param to Addr to get tokens.
     * @param deadline Ignored param.
     * @return amountA Amt of tokenA removed.
     * @return amountB Amt of tokenB removed.
     */
    function removeLiquidity(
        address tokenA_,
        address tokenB_,
        uint256 liquidityAmount,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external override returns (uint256 amountA, uint256 amountB) {
        require(to != address(0), "Inv to addr");
        require(liquidity[msg.sender] >= liquidityAmount, "Insuf liq");
        require(liquidityAmount > 0, "Liq amt must be pos");

        amountA = (liquidityAmount * reserveA) / totalLiquidity;
        amountB = (liquidityAmount * reserveB) / totalLiquidity;
        require(amountA >= amountAMin, "Insuf A amt");
        require(amountB >= amountBMin, "Insuf B amt");

        reserveA -= amountA;
        reserveB -= amountB;
        totalLiquidity -= liquidityAmount;
        liquidity[msg.sender] -= liquidityAmount;

        require(IERC20(tokenA).transfer(to, amountA), "Trans A fail");
        require(IERC20(tokenB).transfer(to, amountB), "Trans B fail");

        emit LiquidityRemoved(to, amountA, amountB);
    }

    /**
     * @notice Performs token swap.
     * @dev Transfers input, sends output.
     * @param amountIn Amt of input tokens (tokenA).
     * @param amountOutMin Min amt of output (tokenB).
     * @param path Token path [tokenA, tokenB].
     * @param to Addr to get output.
     * @param deadline Ignored param.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external override {
        require(to != address(0), "Inv to addr");
        require(path.length == 2, "Inv path len");
        require(path[0] == tokenA && path[1] == tokenB, "Inv token path");

        uint256 amountOut = getAmountOut(amountIn, reserveA, reserveB);
        require(amountOut >= amountOutMin, "Insuf out amt");

        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountIn), "Trans A fail");

        reserveA += amountIn;
        reserveB -= amountOut;

        require(IERC20(tokenB).transfer(to, amountOut), "Trans B fail");

        emit Swap(msg.sender, amountIn, amountOut);
    }

    /**
     * @notice Gets tokenB price in tokenA.
     * @dev Returns price with 1e18 precision.
     * @param _tokenA TokenA addr to verify.
     * @param _tokenB TokenB addr to verify.
     * @return price Price of tokenB in tokenA.
     */
    function getPrice(address _tokenA, address _tokenB) external view override returns (uint256 price) {
        require(_tokenA == tokenA && _tokenB == tokenB, "Inv token pair");
        require(reserveA > 0 && reserveB > 0, "Insuf liq");
        price = (reserveB * 1e18) / reserveA;
    }

    /**
     * @notice Calc output amt.
     * @dev Uses constant product formula.
     * @param amountIn Input amt (tokenA).
     * @param reserveIn Reserve of tokenA.
     * @param reserveOut Reserve of tokenB.
     * @return amountOut Output amt (tokenB).
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure override returns (uint256 amountOut) {
        require(amountIn > 0, "Amt in must be pos");
        require(reserveIn > 0 && reserveOut > 0, "Insuf liq");
        uint256 amountInWithFee = amountIn;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn + amountInWithFee;
        amountOut = numerator / denominator;
        require(amountOut > 0, "Amt out must be pos");
    }
}
