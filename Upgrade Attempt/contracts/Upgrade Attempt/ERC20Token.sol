// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
 * @title ERC20Token
 * @dev Standard ERC20 token implementation.
 */
contract ERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Constructor to initialize the ERC20 token.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _decimals The number of decimal places.
     * @param _initialSupply The initial token supply.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * (10 ** uint256(_decimals));
        _balances[msg.sender] = totalSupply;
    }

    /**
     * @dev Returns the balance of the specified address.
     * @param account The address to query the balance of.
     * @return The balance of the specified address.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Transfers tokens from the sender to the specified recipient.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     * @return True if the transfer was successful, revert otherwise.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Transfers tokens from one address to another.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     * @return True if the transfer was successful, revert otherwise.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint256 allowedAmount = _allowances[from][msg.sender];
        require(allowedAmount >= value, "ERC20: transfer amount exceeds allowedAmount");
        _allowances[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Internal function to perform the actual transfer of tokens.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(_balances[from] >= value, "ERC20: transfer amount exceeds balance");
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    /**
     * @dev Approves the specified address to spend the specified amount of tokens on behalf of the message sender.
     * @param spender The address to approve for spending the tokens.
     * @param value The amount of tokens to be spent.
     * @return True if the approval was successful, revert otherwise.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Returns the amount of tokens that an owner has allowed a spender to spend.
     * @param owner The address that owns the tokens.
     * @param spender The address that is allowed to spend the tokens.
     * @return The amount of tokens allowed to be spent.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
}
