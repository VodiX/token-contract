pragma solidity ^0.5.0;

import "../../zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "../../zeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title TokenCappedCrowdsale
 * @dev Crowdsale with a limit for total tokens for sale.
 */
contract TokenCappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 private _tokenCap;
    uint256 private _totalSupplyCrowdsale;

    /**
     * @dev Constructor, takes maximum amount of tokens for sale in the crowdsale.
     * @param tokenCap Max amount of tokens that can be bought
     */
    constructor (uint256 tokenCap) public {
        require(tokenCap > 0);
        _tokenCap = tokenCap;
    }

    /**
     * @return the amount of tokens sold.
     */
    function totalSupplyCrowdsale() public view returns (uint256) {
        return _totalSupplyCrowdsale;
    }

    /**
     * @return the tokenCap of the crowdsale.
     */
    function tokenCap() public view returns (uint256) {
        return _tokenCap;
    }

    /**
     * @dev Extend parent behavior requiring total purchase to respect the token cap.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _totalSupplyCrowdsale = _totalSupplyCrowdsale.add(tokenAmount);
        require(totalSupplyCrowdsale() <= _tokenCap);
        super._processPurchase(beneficiary, tokenAmount);
    }

    /**
     * @dev Checks whether the tokenCap has been reached.
     * @return Whether the tokenCap was reached
     */
    function tokenCapReached() public view returns (bool) {
        return totalSupplyCrowdsale() >= _tokenCap;
    }
}

