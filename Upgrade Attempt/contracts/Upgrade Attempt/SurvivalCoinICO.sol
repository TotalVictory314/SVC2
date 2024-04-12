// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./SurvivalCoin.sol";

/**
 * @title SurvivalCoinICO
 * @dev ICO contract for SurvivalCoin.
 */
contract SurvivalCoinICO {
    SurvivalCoin public token;
    address public admin;
    address payable public deposit;
    uint256 public tokenPrice;
    uint256 public hardCap;
    uint256 public raisedAmount;
    uint256 public saleStart;
    uint256 public saleEnd;
    uint256 public tokenTradeStart;
    uint256 public maxInvestment;
    uint256 public minInvestment;

    enum State { beforeStart, running, afterEnd, halted }
    State public icoState;

    event Invest(address indexed investor, uint256 value, uint256 tokens);

    /**
     * @dev Constructor to initialize the SurvivalCoin ICO.
     * @param _admin The address of the admin.
     * @param _deposit The address of the deposit.
     * @param _tokenPrice The price of one token in Ether.
     * @param _hardCap The hard cap of the ICO.
     * @param _saleStart The start time of the ICO.
     * @param _saleDuration The duration of the ICO.
     * @param _tokenTradeStart The start time for token trading.
     * @param _maxInvestment The maximum investment per investor.
     * @param _minInvestment The minimum investment per investor.
     */
    constructor(
        address _admin,
        address payable _deposit,
        uint256 _tokenPrice,
        uint256 _hardCap,
        uint256 _saleStart,
        uint256 _saleDuration,
        uint256 _tokenTradeStart,
        uint256 _maxInvestment,
        uint256 _minInvestment
    ) {
        token = new SurvivalCoin(_admin, _hardCap);
        admin = _admin;
        deposit = _deposit;
        tokenPrice = _tokenPrice;
        hardCap = _hardCap;
        saleStart = _saleStart;
        saleEnd = _saleStart + _saleDuration;
        tokenTradeStart = _tokenTradeStart;
        maxInvestment = _maxInvestment;
        minInvestment = _minInvestment;
        icoState = State.beforeStart;
    }

    /**
     * @dev Modifier to check if the ICO is running.
     */
    modifier isRunning() {
        require(icoState == State.running && block.timestamp >= saleStart && block.timestamp <= saleEnd, "SurvivalCoinICO: ICO not running");
        _;
    }

    /**
     * @dev Modifier to check if the ICO is not halted.
     */
    modifier notHalted() {
        require(icoState != State.halted, "SurvivalCoinICO: ICO is halted");
        _;
    }

    /**
     * @dev Modifier to check if the investment amount is within limits.
     */
    modifier withinLimits() {
        require(msg.value >= minInvestment && msg.value <= maxInvestment, "SurvivalCoinICO: investment amount not within limits");
        _;
    }

    /**
     * @dev Modifier to check if the hard cap is not exceeded.
     */
    modifier notExceededHardCap() {
        require(raisedAmount + msg.value <= hardCap, "SurvivalCoinICO: hard cap exceeded");
        _;
    }

    /**
     * @dev Internal function to handle the investment logic.
     */
    function _invest() internal isRunning notHalted withinLimits notExceededHardCap {
        uint256 tokens = (msg.value * (10**uint256(token.decimals()))) / tokenPrice;
        token.transfer(msg.sender, tokens);
        raisedAmount += msg.value;
        deposit.transfer(msg.value);
        emit Invest(msg.sender, msg.value, tokens);
    }

    /**
     * @dev Allows external callers to invest in the ICO.
     */
    function investTokens() external payable {
        _invest();
    }

    /**
     * @dev Fallback function to automatically invest when Ether is sent to the contract.
     */
    receive() external payable {
        _invest();
    }

    /**
     * @dev Allows the admin to halt the ICO.
     */
    function halt() external {
        require(msg.sender == admin, "SurvivalCoinICO: caller is not the admin");
        icoState = State.halted;
    }

    /**
     * @dev Allows the admin to resume the ICO.
     */
    function resume() external {
        require(msg.sender == admin, "SurvivalCoinICO: caller is not the admin");
        icoState = State.running;
    }

    /**
     * @dev Allows the admin to change the deposit address.
     * @param _newDeposit The new deposit address.
     */
    function changeDepositAddress(address payable _newDeposit) external {
        require(msg.sender == admin, "SurvivalCoinICO: caller is not the admin");
        deposit = _newDeposit;
    }

    /**
     * @dev Returns the current state of the ICO.
     */
    function getCurrentState() external view returns (State) {
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < saleStart) {
            return State.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.running;
        } else {
            return State.afterEnd;
        }
    }
}

