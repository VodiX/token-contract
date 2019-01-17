pragma solidity ^0.5.0;

import "../token/ERC20/ERC20.sol";
import "../token/ERC20/ERC20Burnable.sol";
import "../token/ERC20/ERC20Detailed.sol";

contract VodiXSimple is ERC20, ERC20Burnable, ERC20Detailed {

    uint8 public constant DECIMALS = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(DECIMALS));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("Vodi X", "VDX", DECIMALS) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
