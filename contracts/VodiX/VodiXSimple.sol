pragma solidity ^0.5.0;

import "../../zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../zeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "../../zeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";

contract VodiXSimple is ERC20, ERC20Burnable, ERC20Detailed {

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(18));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () ERC20Detailed("Vodi X", "VDX", 18) public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
