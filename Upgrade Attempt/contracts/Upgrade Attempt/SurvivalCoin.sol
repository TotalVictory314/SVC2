// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC20Token.sol";

/**
 * @title SurvivalCoin
 * @dev ERC20 token representing SurvivalCoin.
 */
contract SurvivalCoin is ERC20Token {
    /**
     * @dev Constructor to initialize the SurvivalCoin token.
     * @param _admin The address of the admin.
     * @param _initialSupply The initial token supply.
     */
    constructor(address _admin, uint256 _initialSupply) ERC20Token("SurvivalCoin", "SVC2", 0, _initialSupply) {
        admin = _admin;
    }

    address public admin;

    /**
     * @dev Modifier to restrict access to the admin.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "SurvivalCoin: caller is not the admin");
        _;
    }

    /**
     * @dev Allows the admin to burn all remaining tokens.
     * @return True if the burn was successful.
     */
    function burn() external onlyAdmin returns (bool) {
        _burn(msg.sender, balanceOf(msg.sender));
        return true;
    }

    /**
     * @dev Internal function to burn tokens from a specified address.
     * @param account The address to burn tokens from.
     * @param value The amount of tokens to burn.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "SurvivalCoin: burn from the zero address");
        require(_balances[account] >= value, "SurvivalCoin: burn amount exceeds balance");
        _balances[account] -= value;
        totalSupply -= value;
        emit Transfer(account, address(0), value);
    }
}
