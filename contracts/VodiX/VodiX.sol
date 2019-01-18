pragma solidity ^0.5.0;

import "../token/ERC20.sol";

contract VodiX is ERC20 {

    string internal _name = "Vodi X";
    string internal _symbol = "VDX";
    uint8 internal _decimals = 18;

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}
